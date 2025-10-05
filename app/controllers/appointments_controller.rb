class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [:show, :cancel]

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

    # Build appointment from params
    @appointment = Appointment.new(appointment_params)
    @appointment.patient = current_user

    # Set provider from service
    @service = Service.find(params[:appointment][:service_id])
    @appointment.provider = @service.provider_profile.user
    @appointment.status = :scheduled

    # Find and lock the availability slot
    @availability = Availability.find(params[:appointment][:availability_id])

    # Check if availability is still available
    if @availability.is_booked?
      redirect_to new_appointment_path, alert: "This time slot has already been booked. Please choose another time."
      return
    end

    # Save appointment and lock availability in transaction
    saved = ActiveRecord::Base.transaction do
      if @appointment.save
        # Mark availability as booked
        @availability.update!(is_booked: true)
        true  # Return true to indicate success
      else
        false  # Return false to indicate failure
      end
    end

    if saved
      # TODO: Uncomment when AppointmentMailer is implemented
      # AppointmentMailer.booking_confirmation(@appointment).deliver_later
      # AppointmentMailer.provider_booking_notification(@appointment).deliver_later

      # Redirect to Stripe payment (will be implemented)
      redirect_to @appointment, notice: "Appointment booked successfully! Please complete payment to confirm."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_appointment_path, alert: "Invalid availability slot selected."
  rescue ActiveRecord::RecordInvalid => e
    @appointment ||= Appointment.new
    flash.now[:alert] = "Failed to book appointment: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def cancel
    authorize @appointment

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

      # Send cancellation notifications
      AppointmentMailer.cancellation_notification(@appointment, @appointment.patient).deliver_later
      AppointmentMailer.cancellation_notification(@appointment, @appointment.provider).deliver_later

      redirect_to appointments_path, notice: "Appointment cancelled successfully."
    else
      redirect_to @appointment, alert: "Failed to cancel appointment."
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
