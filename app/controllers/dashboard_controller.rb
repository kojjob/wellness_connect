class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_provider

  def index
    @provider_profile = current_user.provider_profile
    @services = @provider_profile.services.order(created_at: :desc)
    @availabilities = @provider_profile.availabilities.where("start_time >= ?", Time.current).order(start_time: :asc).limit(10)
    @total_services = @provider_profile.services.count
    @total_availability_slots = @provider_profile.availabilities.where(is_booked: false).where("start_time >= ?", Time.current).count

    render :provider_dashboard
  end

  private

  def require_provider
    unless current_user.provider?
      redirect_to root_url, alert: "You must be a provider to access the dashboard."
    end
  end
end
