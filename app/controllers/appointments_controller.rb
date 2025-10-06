class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :show, :cancel ]

  def index
    authorize Appointment

    if current_user.patient?
      @appointments = current_user.appointments_as_patient
                                 .includes(:provider, :service)
                                 .order(start_time: :desc)
    elsif current_user.provider?
      @appointments = current_user.appointments_as_provider
                                 .includes(:patient, :service)
                                 .order(start_time: :desc)
    else
      @appointments = Appointment.none
    end

    # Filter by status if provided
    @appointments = @appointments.where(status: params[:status]) if params[:status].present?
  end

  def show
    authorize @appointment
    @service = @appointment.service
    @provider = @appointment.provider
    @patient = @appointment.patient
  end

  def new
    authorize Appointment, :create?

    # Get service and availability from params
    @service = Service.find(params[:service_id]) if params[:service_id].present?
    @availability = Availability.find(params[:availability_id]) if params[:availability_id].present?

    # Build new appointment
    @appointment = Appointment.new(
      patient: current_user,
      provider: @service&.provider_profile&.user,
      service: @service,
      start_time: @availability&.start_time,
      end_time: @availability&.end_time
    )
  end

  def create
    authorize Appointment, :create?

    ActiveRecord::Base.transaction do
      # Build appointment from params
      @appointment = Appointment.new(appointment_params)
      @appointment.patient = current_user
      @appointment.status = :scheduled

      # Find and lock the availability slot
      @availability = Availability.find(params[:appointment][:availability_id])

      # Check if availability is still available
      if @availability.is_booked?
        redirect_to new_appointment_path(service_id: params[:appointment][:service_id]), error: "⚠ This time slot has already been booked. Please choose another time." and return
      end

      # Save appointment and lock availability
      if @appointment.save
        # Mark availability as booked
        @availability.update!(is_booked: true)

        # Send confirmation emails
        AppointmentMailer.booking_confirmation(@appointment).deliver_later
        AppointmentMailer.provider_booking_notification(@appointment).deliver_later

        # Create detailed success message
        success_message = "✓ Appointment booked successfully! Your appointment with #{@appointment.provider.full_name} is scheduled for #{@appointment.start_time.strftime('%A, %B %d at %I:%M %p')}. Please complete payment to confirm."

        # Redirect to Stripe payment (will be implemented)
        redirect_to @appointment, notice: success_message
      else
        # Set detailed error message
        @service = Service.find(params[:appointment][:service_id]) if params[:appointment][:service_id].present?
        flash.now[:error] = "Unable to book appointment. #{@appointment.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_appointment_path, error: "⚠ Invalid availability slot selected. Please choose another time slot."
  rescue ActiveRecord::RecordInvalid => e
    @appointment ||= Appointment.new
    @service = Service.find(params[:appointment][:service_id]) if params[:appointment][:service_id].present?
    flash.now[:error] = "⚠ Failed to book appointment: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def cancel
    authorize @appointment

    ActiveRecord::Base.transaction do
      # Update appointment status
      if @appointment.update(
        status: current_user.patient? ? :cancelled_by_patient : :cancelled_by_provider,
        cancellation_reason: params[:cancellation_reason]
      )
        # Release the availability slot
        availability = Availability.find_by(
          provider_profile: @appointment.service.provider_profile,
          start_time: @appointment.start_time,
          end_time: @appointment.end_time
        )
        availability&.update(is_booked: false)

        # Process refund if payment exists and was successful
        payment = @appointment.payment
        refund_message = ""

        if payment&.succeeded?
          refund_result = RefundService.process_refund(payment, params[:cancellation_reason] || "Appointment cancelled")

          if refund_result[:success]
            case refund_result[:refund_type]
            when "full"
              refund_message = " A full refund of $#{refund_result[:refund_amount].round(2)} will be processed."
            when "partial"
              refund_message = " A partial refund of $#{refund_result[:refund_amount].round(2)} (50%) will be processed."
            when "none"
              refund_message = " Per our cancellation policy, no refund is available for cancellations less than 24 hours before the appointment."
            end
          else
            refund_message = " There was an issue processing your refund. Our support team will contact you shortly."
            Rails.logger.error "Refund failed for appointment #{@appointment.id}: #{refund_result[:error]}"
          end
        end

        # Send cancellation notifications
        NotificationService.notify_appointment_cancelled(@appointment, current_user)

        redirect_to appointments_path, notice: "Appointment cancelled successfully.#{refund_message}"
      else
        redirect_to @appointment, alert: "Failed to cancel appointment."
      end
    end
  rescue StandardError => e
    Rails.logger.error "Error cancelling appointment #{@appointment.id}: #{e.message}"
    redirect_to @appointment, alert: "An error occurred while cancelling the appointment. Please try again or contact support."
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:service_id, :provider_id, :start_time, :end_time, :availability_id, :notes)
  end
end
