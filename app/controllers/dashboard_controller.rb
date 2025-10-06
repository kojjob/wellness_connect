class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.admin? || current_user.super_admin?
      redirect_to admin_root_path
    elsif current_user.provider?
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
    @total_services = @provider_profile.services.count
    @total_availability_slots = @provider_profile.availabilities.where(is_booked: false).where("start_time >= ?", Time.current).count
    @appointments = current_user.appointments_as_provider.order(start_time: :desc).limit(10)

    # Revenue statistics
    @total_earnings = Payment.joins(:appointment)
                             .where(appointments: { provider_id: current_user.id })
                             .where(status: :succeeded)
                             .sum(:amount)

    @earnings_this_month = Payment.joins(:appointment)
                                  .where(appointments: { provider_id: current_user.id })
                                  .where(status: :succeeded)
                                  .where("payments.created_at >= ?", Time.current.beginning_of_month)
                                  .sum(:amount)

    @recent_payments = Payment.joins(:appointment)
                              .where(appointments: { provider_id: current_user.id })
                              .where(status: [ :succeeded, :refunded ])
                              .order(created_at: :desc)
                              .limit(5)

    render :provider_dashboard
  end

  def render_patient_dashboard
    # Upcoming appointments (next 5, scheduled only)
    @upcoming_appointments = current_user.appointments_as_patient
                                         .where(status: :scheduled)
                                         .where("start_time >= ?", Time.current)
                                         .order(start_time: :asc)
                                         .limit(5)
                                         .includes(:provider, :service, :payment)

    # Recent completed appointments (for health records)
    @recent_health_records = current_user.appointments_as_patient
                                         .where(status: :completed)
                                         .order(start_time: :desc)
                                         .limit(5)
                                         .includes(:provider, :service, :consultation_note)

    # Unread notifications
    @unread_notifications = current_user.notifications.unread.order(created_at: :desc).limit(5)

    # Recent payments
    @recent_payments = current_user.payments_made
                                   .where(status: [ :succeeded, :refunded ])
                                   .order(created_at: :desc)
                                   .limit(3)
                                   .includes(appointment: [ :provider, :service ])

    # Quick stats
    @total_appointments = current_user.appointments_as_patient.count
    @upcoming_count = @upcoming_appointments.count
    @unread_messages_count = @unread_notifications.count
    @total_spent = current_user.payments_made.where(status: :succeeded).sum(:amount)

    # Recommended providers (providers with highest ratings that patient hasn't booked yet)
    booked_provider_ids = current_user.appointments_as_patient.pluck(:provider_id).uniq
    @recommended_providers = ProviderProfile.joins(:user)
                                            .where.not(user_id: booked_provider_ids)
                                            .where.not(user_id: current_user.id)
                                            .limit(3)
                                            .includes(:user, :reviews)

    render :patient_dashboard
  end
end
