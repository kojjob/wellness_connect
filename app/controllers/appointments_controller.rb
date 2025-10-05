class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :show, :cancel ]

  def index
    # Cache appointments list for 5 minutes since it changes frequently with new bookings
    cache_key = [ "user_appointments", current_user.id, current_user.role ]

    @appointments = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      appointments = if current_user.patient?
        current_user.appointments_as_patient
                   .includes(:service, :provider, provider: :provider_profile)
                   .order(start_time: :asc)
      else
        current_user.appointments_as_provider
                   .includes(:service, :patient, patient: :patient_profile)
                   .order(start_time: :asc)
      end
      appointments.to_a # Force query execution and cache result array
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

    # Check if appointment can be cancelled
    if @appointment.cancelled_by_patient? || @appointment.cancelled_by_provider? || @appointment.cancelled_by_system?
      return redirect_to dashboard_path, alert: "This appointment is already cancelled"
    end

    if @appointment.completed?
      return redirect_to dashboard_path, alert: "Cannot cancel a completed appointment"
    end

    ActiveRecord::Base.transaction do
      # Determine cancellation status
      cancellation_status = current_user.patient? ? :cancelled_by_patient : :cancelled_by_provider

      # Update appointment status
      @appointment.update!(
        status: cancellation_status,
        cancellation_reason: params[:cancellation_reason]
      )

      # Process refund if applicable
      process_refund if should_refund?

      # Release availability slot
      availability = Availability.find_by(
        provider_profile: @appointment.service.provider_profile,
        start_time: @appointment.start_time,
        end_time: @appointment.end_time
      )
      availability&.update(is_booked: false)

      # Create notification for the other party
      NotificationService.notify_appointment_cancelled(@appointment, current_user)
    end

    redirect_to dashboard_path, notice: "Appointment cancelled successfully"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to dashboard_path, alert: "Failed to cancel appointment: #{e.message}"
  rescue Stripe::StripeError => e
    # Even if refund fails, appointment should be cancelled
    redirect_to dashboard_path, alert: "Appointment cancelled but refund failed: #{e.message}"
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def should_refund?
    payment = @appointment.payment
    return false unless payment&.succeeded?
    return false if payment.refunded?

    # Provider cancellation: always refund
    return true if current_user.provider?

    # Patient cancellation: only refund if >24 hours before appointment
    time_until_appointment = @appointment.start_time - Time.current
    time_until_appointment > 24.hours
  end

  def process_refund
    payment = @appointment.payment
    return unless payment

    begin
      # Create Stripe refund
      refund = Stripe::Refund.create(
        payment_intent: payment.stripe_payment_intent_id,
        metadata: {
          appointment_id: @appointment.id,
          reason: params[:cancellation_reason] || "Appointment cancelled"
        }
      )

      # Update payment record
      payment.update!(
        status: :refunded,
        refunded_at: Time.current
      )

      Rails.logger.info "Refund processed for payment #{payment.id}: #{refund.id}"
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe refund failed for payment #{payment.id}: #{e.message}"
      # Re-raise to be caught by outer rescue block
      raise
    end
  end

  def appointment_params
    params.require(:appointment).permit(:service_id, :provider_id, :start_time, :end_time)
  end
end
