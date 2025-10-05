class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.provider?
      render_provider_dashboard
    elsif current_user.patient?
      render_patient_dashboard
    else
      redirect_to root_url, alert: "Please complete your profile to access the dashboard."
    end
  end

  private

  def render_provider_dashboard
    @provider_profile = current_user.provider_profile

    unless @provider_profile
      redirect_to new_provider_profile_path, alert: "Please complete your provider profile to access the dashboard."
      return
    end

    @services = @provider_profile.services.order(created_at: :desc)
    @availabilities = @provider_profile.availabilities.where("start_time >= ?", Time.current).order(start_time: :asc).limit(10)
    # Use counter cache instead of COUNT(*) query
    @total_services = @provider_profile.services_count
    # Calculate available slots with single query (optimized with composite index)
    @total_availability_slots = @provider_profile.availabilities.where(is_booked: false, start_time: Time.current..).count
    @appointments = current_user.appointments_as_provider
                                .includes(:service, :patient, patient: :patient_profile)
                                .order(start_time: :desc)
                                .limit(10)

    render :provider_dashboard
  end

  def render_patient_dashboard
    @appointments = current_user.appointments_as_patient
                                .includes(:service, :provider, provider: :provider_profile)
                                .order(start_time: :asc)

    render :patient_dashboard
  end
end
