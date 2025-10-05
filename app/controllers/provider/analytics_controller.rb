class Provider::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider_role

  def index
    @provider = current_user

    # Revenue analytics
    @total_revenue = @provider.total_revenue
    @average_session_price = @provider.average_session_price
    @revenue_by_month = @provider.revenue_by_month(months_back: 6)
    @revenue_by_week = @provider.revenue_by_week(weeks_back: 8)

    # Appointment analytics
    @total_appointments = @provider.total_appointments
    @appointment_status_breakdown = @provider.appointment_status_breakdown

    # Patient analytics
    @unique_patients_count = @provider.unique_patients_count

    # Service analytics
    @top_services = @provider.top_services_by_revenue(limit: 5)

    # Date range filters (if provided)
    if params[:start_date].present? || params[:end_date].present?
      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
      end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

      @filtered_revenue = @provider.total_revenue(start_date: start_date, end_date: end_date)
      @filtered_appointments = @provider.total_appointments(start_date: start_date, end_date: end_date)
      @filtered_patients = @provider.unique_patients_count(start_date: start_date, end_date: end_date)
    end
  end

  private

  def ensure_provider_role
    unless current_user.provider?
      redirect_to root_path, alert: "Access denied. This page is only available to service providers."
    end
  end
end
