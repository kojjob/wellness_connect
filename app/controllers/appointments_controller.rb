class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :show, :cancel ]

  def index
    @appointments = if current_user.patient?
      current_user.appointments_as_patient.order(start_time: :asc)
    else
      current_user.appointments_as_provider.order(start_time: :asc)
    end
  end

  def new
    @availability = Availability.find(params[:availability_id])
    @provider_profile = @availability.provider_profile
    @services = @provider_profile.services.where(is_active: true)
    @appointment = Appointment.new(
      patient: current_user,
      provider: @provider_profile.user,
      start_time: @availability.start_time,
      end_time: @availability.end_time
    )
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.patient = current_user
    # Status defaults to payment_pending

    # Get availability and service
    availability = Availability.find(params[:availability_id])
    service = @appointment.service

    ActiveRecord::Base.transaction do
      if @appointment.save
        # Mark availability as booked to prevent double-booking during payment
        availability.update!(is_booked: true)

        begin
          # Create Stripe Payment Intent
          payment_intent = Stripe::PaymentIntent.create(
            amount: (service.price.to_f * 100).to_i, # Stripe uses cents
            currency: "usd",
            metadata: {
              appointment_id: @appointment.id,
              patient_id: current_user.id,
              provider_id: @appointment.provider.id
            }
          )

          # Create Payment record
          payment = Payment.create!(
            payer: current_user,
            appointment: @appointment,
            amount: service.price,
            currency: "USD",
            status: :pending,
            stripe_payment_intent_id: payment_intent.id
          )

          # Return payment info for frontend
          respond_to do |format|
            format.html { redirect_to dashboard_path, notice: "Please complete payment to confirm your appointment." }
            format.json do
              render json: {
                success: true,
                appointment_id: @appointment.id,
                client_secret: payment_intent.client_secret,
                payment_intent_id: payment_intent.id,
                payment_id: payment.id,
                amount: service.price
              }, status: :ok
            end
          end
        rescue Stripe::StripeError => e
          # Payment Intent creation failed - rollback appointment and availability
          availability.update!(is_booked: false)
          @appointment.destroy

          respond_to do |format|
            format.html do
              @availability = availability
              @provider_profile = availability.provider_profile
              @services = @provider_profile.services.where(is_active: true)
              flash.now[:alert] = "Payment processing error: #{e.message}"
              render :new, status: :unprocessable_entity
            end
            format.json { render json: { error: e.message }, status: :unprocessable_entity }
          end
        end
      else
        @availability = availability
        @provider_profile = availability.provider_profile
        @services = @provider_profile.services.where(is_active: true)

        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @availability = availability
    @provider_profile = availability.provider_profile
    @services = @provider_profile.services.where(is_active: true)

    respond_to do |format|
      format.html do
        flash.now[:alert] = "Failed to book appointment: #{e.message}"
        render :new, status: :unprocessable_entity
      end
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def show
    authorize @appointment
  end

  def cancel
    authorize @appointment

    if @appointment.update(
      status: current_user.patient? ? :cancelled_by_patient : :cancelled_by_provider,
      cancellation_reason: params[:cancellation_reason]
    )
      # Release availability slot
      availability = Availability.find_by(
        provider_profile: @appointment.service.provider_profile,
        start_time: @appointment.start_time,
        end_time: @appointment.end_time
      )
      availability&.update(is_booked: false)

      # Create notification for the other party
      NotificationService.notify_appointment_cancelled(@appointment, current_user)

      redirect_to dashboard_path, notice: "Appointment cancelled successfully"
    else
      redirect_to dashboard_path, alert: "Failed to cancel appointment"
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:service_id, :provider_id, :start_time, :end_time)
  end
end
