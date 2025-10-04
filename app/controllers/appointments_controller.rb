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
    @appointment.status = :scheduled

    # Get availability and mark as booked
    availability = Availability.find(params[:availability_id])

    ActiveRecord::Base.transaction do
      if @appointment.save
        availability.update!(is_booked: true)

        # Send confirmation emails
        AppointmentMailer.booking_confirmation(@appointment).deliver_later
        AppointmentMailer.provider_booking_notification(@appointment).deliver_later

        redirect_to dashboard_path, notice: "Appointment successfully booked!"
      else
        @availability = availability
        @provider_profile = availability.provider_profile
        @services = @provider_profile.services.where(is_active: true)
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @availability = availability
    @provider_profile = availability.provider_profile
    @services = @provider_profile.services.where(is_active: true)
    flash.now[:alert] = "Failed to book appointment: #{e.message}"
    render :new, status: :unprocessable_entity
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

      # Send cancellation notifications to both patient and provider
      AppointmentMailer.cancellation_notification(@appointment, @appointment.patient).deliver_later
      AppointmentMailer.cancellation_notification(@appointment, @appointment.provider).deliver_later

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
