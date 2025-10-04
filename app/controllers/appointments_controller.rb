class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :show, :cancel ]

  def index
    @appointments = current_user.appointments_as_patient.order(start_time: :asc)
  end

  def new
    @availability = Availability.find(params[:availability_id])
    @provider_profile = @availability.provider_profile
    @appointment = Appointment.new
    @services = @provider_profile.services.where(is_active: true)
  end

  def create
    @availability = Availability.find(params[:availability_id])
    @service = Service.find(params[:appointment][:service_id])

    @appointment = Appointment.new(
      patient: current_user,
      provider: @availability.provider_profile.user,
      service: @service,
      start_time: @availability.start_time,
      end_time: @availability.end_time,
      status: :scheduled
    )

    if @appointment.save
      # Mark availability as booked
      @availability.update!(is_booked: true)

      redirect_to dashboard_path, notice: "Appointment successfully booked."
    else
      @provider_profile = @availability.provider_profile
      @services = @provider_profile.services.where(is_active: true)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  def cancel
    if @appointment.update(
      status: :cancelled_by_patient,
      cancellation_reason: params[:cancellation_reason]
    )
      # Release the availability slot
      availability = Availability.find_by(
        provider_profile: @appointment.provider.provider_profile,
        start_time: @appointment.start_time,
        end_time: @appointment.end_time
      )
      availability&.update!(is_booked: false)

      redirect_to dashboard_path, notice: "Appointment cancelled successfully."
    else
      redirect_to dashboard_path, alert: "Failed to cancel appointment."
    end
  end

  private

  def set_appointment
    @appointment = current_user.appointments_as_patient.find(params[:id])
  end
end
