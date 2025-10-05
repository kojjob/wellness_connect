module Admin
  class DashboardController < BaseController
    def index
      # Platform statistics
      @total_users = User.count
      @total_patients = User.where(role: "patient").count
      @total_providers = User.where(role: "provider").count
      @total_admins = User.where(role: "admin").count

      # Provider statistics
      @total_provider_profiles = ProviderProfile.count
      @total_services = Service.count
      @total_availabilities = Availability.count

      # Appointment statistics
      @total_appointments = Appointment.count
      @scheduled_appointments = Appointment.where(status: "scheduled").count
      @completed_appointments = Appointment.where(status: "completed").count
      @cancelled_appointments = Appointment.where(status: [ "cancelled_by_patient", "cancelled_by_provider" ]).count

      # Payment statistics
      @total_payments = Payment.count
      @successful_payments = Payment.where(status: "succeeded").count
      @pending_payments = Payment.where(status: "pending").count
      @failed_payments = Payment.where(status: "failed").count
      @total_revenue = Payment.where(status: "succeeded").sum(:amount) / 100.0 # Convert from cents

      # Review statistics
      @total_reviews = Review.count
      @average_platform_rating = Review.average(:rating)&.round(1) || 0.0

      # Recent activity
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_appointments = Appointment.includes(:patient, :provider, :service).order(created_at: :desc).limit(5)
      @recent_payments = Payment.includes(:payer).order(created_at: :desc).limit(5)
    end
  end
end
