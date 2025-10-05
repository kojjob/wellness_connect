module Admin
  class DashboardController < BaseController
    def index
      # Date range filtering
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil
      date_range_options = { start_date: @start_date, end_date: @end_date }

      # Platform Statistics (using Analytics::PlatformAnalytics class methods with date range)
      @total_users = User.total_users_count(**date_range_options)
      @total_patients = User.total_patients_count(**date_range_options)
      @total_providers = User.total_providers_count(**date_range_options)
      @total_admins = User.where(role: "admin").count

      # Provider Statistics
      @total_provider_profiles = ProviderProfile.count
      @total_services = Service.count
      @total_availabilities = Availability.count

      # Appointment Statistics (using Analytics methods with date range)
      @total_appointments = User.total_appointments_count(**date_range_options)
      @appointments_by_status = User.appointments_by_status(**date_range_options)
      @scheduled_appointments = @appointments_by_status["scheduled"] || 0
      @completed_appointments = @appointments_by_status["completed"] || 0
      @cancelled_appointments = (@appointments_by_status["cancelled_by_patient"] || 0) + (@appointments_by_status["cancelled_by_provider"] || 0)

      # Payment Statistics (using Analytics methods with date range)
      @total_revenue = User.total_platform_revenue(**date_range_options)
      @average_transaction_value = User.average_transaction_value
      @payment_success_rate = User.payment_success_rate
      @total_payments = Payment.count
      @successful_payments = Payment.where(status: "succeeded").count
      @pending_payments = Payment.where(status: "pending").count
      @failed_payments = Payment.where(status: "failed").count

      # Review Statistics
      @total_reviews = Review.count
      @average_platform_rating = Review.average(:rating)&.round(1) || 0.0

      # Growth Analytics (using Analytics methods)
      @users_growth_by_month = User.users_growth_by_month(6) # Last 6 months
      @revenue_by_month = User.platform_revenue_by_month(6) # Last 6 months

      # Top Performers (using Analytics methods)
      @top_providers_by_revenue = User.top_providers_by_revenue(5)
      @top_services_by_bookings = User.top_services_by_bookings(5)

      # Recent Activity
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_appointments = Appointment.includes(:patient, :provider, :service).order(created_at: :desc).limit(5)
      @recent_payments = Payment.includes(:payer).order(created_at: :desc).limit(5)
    end

    def export
      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
      end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

      csv_data = AnalyticsExporter.export_platform_analytics_csv(
        start_date: start_date,
        end_date: end_date
      )

      filename = "platform_analytics_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

      send_data csv_data,
                type: 'text/csv; charset=utf-8',
                disposition: "attachment; filename=#{filename}"
    end
  end
end
