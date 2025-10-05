class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.admin?
      redirect_to admin_users_path
    elsif current_user.provider?
      render_provider_dashboard
    elsif current_user.patient?
      render_patient_dashboard
    else
      redirect_to root_url, alert: "Please complete your profile to access the dashboard."
    end
  end

  def export
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

    exporter = AnalyticsExporter.new(current_user, start_date: start_date, end_date: end_date)

    csv_data = if current_user.provider?
      exporter.export_provider_revenue_csv
    elsif current_user.patient?
      exporter.export_patient_analytics_csv
    else
      redirect_to dashboard_path, alert: "Export not available for your account type."
      return
    end

    filename = "#{current_user.role}_analytics_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    send_data csv_data,
              type: 'text/csv; charset=utf-8',
              disposition: "attachment; filename=#{filename}"
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
    @total_services = @provider_profile.services.count
    @total_availability_slots = @provider_profile.availabilities.where(is_booked: false).where("start_time >= ?", Time.current).count
    @appointments = current_user.appointments_as_provider.order(start_time: :desc).limit(10)

    # Revenue Analytics (using Analytics concern methods)
    @total_earnings = current_user.total_revenue
    @earnings_this_month = current_user.revenue_for_period(Time.current.beginning_of_month, Time.current.end_of_month)
    @revenue_by_month = current_user.revenue_by_month(6) # Last 6 months
    @revenue_by_service = current_user.revenue_by_service
    @average_revenue_per_appointment = current_user.average_revenue_per_appointment

    # Appointment Analytics (using Analytics concern methods)
    @total_appointments = current_user.total_appointments_count
    @completed_appointments = current_user.completed_appointments_count
    @scheduled_appointments = current_user.scheduled_appointments_count
    @cancelled_appointments = current_user.cancelled_appointments_count
    @no_show_appointments = current_user.no_show_appointments_count

    # Performance Metrics
    @completion_rate = current_user.completion_rate
    @cancellation_rate = current_user.cancellation_rate
    @no_show_rate = current_user.no_show_rate
    @average_appointments_per_week = current_user.average_appointments_per_week

    # Appointment Trends
    @appointments_by_month = current_user.appointments_by_month(6) # Last 6 months
    @appointments_by_status = current_user.appointments_by_status
    @peak_booking_hours = current_user.peak_booking_hours

    # Recent Payments
    @recent_payments = Payment.joins(:appointment)
                              .where(appointments: { provider_id: current_user.id })
                              .where(status: [ :succeeded, :refunded ])
                              .order(created_at: :desc)
                              .limit(5)

    render :provider_dashboard
  end

  def render_patient_dashboard
    @appointments = current_user.appointments_as_patient.order(start_time: :asc)

    render :patient_dashboard
  end
end
