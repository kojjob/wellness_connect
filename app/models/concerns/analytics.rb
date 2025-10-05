# frozen_string_literal: true

# Analytics concern providing shared analytics functionality
# Can be included in User, ProviderProfile, or other models needing analytics

module Analytics
  extend ActiveSupport::Concern

  # Provider Revenue Analytics
  module ProviderRevenue
    extend ActiveSupport::Concern

    def total_revenue(start_date: nil, end_date: nil)
      query = Payment.joins(:appointment)
                     .where(appointments: { provider_id: id })
                     .where(status: :succeeded)

      query = query.where("payments.created_at >= ?", start_date) if start_date.present?
      query = query.where("payments.created_at <= ?", end_date) if end_date.present?

      query.sum(:amount)
    end

    def revenue_for_period(start_date, end_date)
      Payment.joins(:appointment)
             .where(appointments: { provider_id: id })
             .where(status: :succeeded)
             .where("payments.created_at >= ? AND payments.created_at <= ?", start_date, end_date)
             .sum(:amount)
    end

    def revenue_by_month(months = 12)
      end_date = Time.current.end_of_month
      start_date = (months - 1).months.ago.beginning_of_month

      Payment.joins(:appointment)
             .where(appointments: { provider_id: id })
             .where(status: :succeeded)
             .where("payments.created_at >= ?", start_date)
             .group("DATE_TRUNC('month', payments.created_at)")
             .sum(:amount)
             .transform_keys { |date| date.strftime("%B %Y") }
    end

    def revenue_by_week(weeks = 12)
      end_date = Time.current.end_of_week
      start_date = (weeks - 1).weeks.ago.beginning_of_week

      Payment.joins(:appointment)
             .where(appointments: { provider_id: id })
             .where(status: :succeeded)
             .where("payments.created_at >= ?", start_date)
             .group("DATE_TRUNC('week', payments.created_at)")
             .sum(:amount)
             .transform_keys { |date| date.strftime("Week of %b %d, %Y") }
    end

    def revenue_by_service(start_date: nil, end_date: nil)
      query = Payment.joins(appointment: :service)
                     .where(appointments: { provider_id: id })
                     .where(status: :succeeded)

      query = query.where("payments.created_at >= ?", start_date) if start_date.present?
      query = query.where("payments.created_at <= ?", end_date) if end_date.present?

      query.group("services.name")
           .sum(:amount)
    end

    def average_revenue_per_appointment
      total = total_revenue
      count = completed_appointments_count
      count.zero? ? 0 : (total.to_f / count).round(2)
    end
  end

  # Provider Appointment Analytics
  module ProviderAppointments
    extend ActiveSupport::Concern

    def total_appointments_count(start_date: nil, end_date: nil)
      query = Appointment.where(provider_id: id)
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def scheduled_appointments_count(start_date: nil, end_date: nil)
      query = Appointment.where(provider_id: id, status: :scheduled)
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def completed_appointments_count(start_date: nil, end_date: nil)
      query = Appointment.where(provider_id: id, status: :completed)
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def cancelled_appointments_count(start_date: nil, end_date: nil)
      query = Appointment.where(provider_id: id)
                         .where(status: [ :cancelled_by_patient, :cancelled_by_provider ])
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def no_show_appointments_count(start_date: nil, end_date: nil)
      query = Appointment.where(provider_id: id, status: :no_show)
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def completion_rate
      total = total_appointments_count
      return 0 if total.zero?

      completed = completed_appointments_count
      ((completed.to_f / total) * 100).round(2)
    end

    def cancellation_rate
      total = total_appointments_count
      return 0 if total.zero?

      cancelled = cancelled_appointments_count
      ((cancelled.to_f / total) * 100).round(2)
    end

    def no_show_rate
      total = total_appointments_count
      return 0 if total.zero?

      no_shows = no_show_appointments_count
      ((no_shows.to_f / total) * 100).round(2)
    end

    def appointments_by_month(months = 12)
      start_date = (months - 1).months.ago.beginning_of_month

      Appointment.where(provider_id: id)
                 .where("start_time >= ?", start_date)
                 .group("DATE_TRUNC('month', start_time)")
                 .count
                 .transform_keys { |date| date.strftime("%B %Y") }
    end

    def appointments_by_status
      Appointment.where(provider_id: id)
                 .group(:status)
                 .count
    end

    def peak_booking_hours
      Appointment.where(provider_id: id)
                 .group("EXTRACT(HOUR FROM start_time)")
                 .count
                 .sort_by { |hour, count| -count }
                 .first(5)
                 .to_h
    end

    def average_appointments_per_week
      first_appointment = Appointment.where(provider_id: id).order(:start_time).first
      return 0 unless first_appointment

      weeks_active = ((Time.current - first_appointment.start_time) / 1.week).ceil
      total = total_appointments_count

      weeks_active.zero? ? 0 : (total.to_f / weeks_active).round(2)
    end
  end

  # Client/Patient Analytics
  module PatientAnalytics
    extend ActiveSupport::Concern

    def total_spent(start_date: nil, end_date: nil)
      query = Payment.joins(:appointment)
                     .where(appointments: { patient_id: id })
                     .where(status: :succeeded)

      query = query.where("payments.created_at >= ?", start_date) if start_date.present?
      query = query.where("payments.created_at <= ?", end_date) if end_date.present?

      query.sum(:amount)
    end

    def spending_by_month(months = 12)
      start_date = (months - 1).months.ago.beginning_of_month

      Payment.joins(:appointment)
             .where(appointments: { patient_id: id })
             .where(status: :succeeded)
             .where("payments.created_at >= ?", start_date)
             .group("DATE_TRUNC('month', payments.created_at)")
             .sum(:amount)
             .transform_keys { |date| date.strftime("%B %Y") }
    end

    def total_sessions_count(start_date: nil, end_date: nil)
      query = Appointment.where(patient_id: id)
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def completed_sessions_count(start_date: nil, end_date: nil)
      query = Appointment.where(patient_id: id, status: :completed)
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def upcoming_sessions_count(start_date: nil, end_date: nil)
      query = Appointment.where(patient_id: id, status: :scheduled)
                         .where("start_time > ?", Time.current)
      query = query.where("start_time >= ?", start_date) if start_date.present?
      query = query.where("start_time <= ?", end_date) if end_date.present?
      query.count
    end

    def favorite_providers(limit = 5)
      Appointment.where(patient_id: id)
                 .group(:provider_id)
                 .count
                 .sort_by { |provider_id, count| -count }
                 .first(limit)
                 .map { |provider_id, count| { provider: User.find(provider_id), sessions: count } }
    end

    def average_spending_per_session
      total = total_spent
      count = completed_sessions_count
      count.zero? ? 0 : (total.to_f / count).round(2)
    end
  end

  # Platform-wide Admin Analytics
  module PlatformAnalytics
    extend ActiveSupport::Concern

    class_methods do
      def total_users_count(start_date: nil, end_date: nil)
        query = User.all
        query = query.where("created_at >= ?", start_date) if start_date.present?
        query = query.where("created_at <= ?", end_date) if end_date.present?
        query.count
      end

      def total_providers_count(start_date: nil, end_date: nil)
        query = User.provider
        query = query.where("created_at >= ?", start_date) if start_date.present?
        query = query.where("created_at <= ?", end_date) if end_date.present?
        query.count
      end

      def total_patients_count(start_date: nil, end_date: nil)
        query = User.patient
        query = query.where("created_at >= ?", start_date) if start_date.present?
        query = query.where("created_at <= ?", end_date) if end_date.present?
        query.count
      end

      def users_growth_by_month(months = 12)
        start_date = (months - 1).months.ago.beginning_of_month

        User.where("created_at >= ?", start_date)
            .group("DATE_TRUNC('month', created_at)")
            .count
            .transform_keys { |date| date.strftime("%B %Y") }
      end

      def total_platform_revenue(start_date: nil, end_date: nil)
        query = Payment.where(status: :succeeded)
        query = query.where("created_at >= ?", start_date) if start_date.present?
        query = query.where("created_at <= ?", end_date) if end_date.present?
        query.sum(:amount)
      end

      def platform_revenue_by_month(months = 12)
        start_date = (months - 1).months.ago.beginning_of_month

        Payment.where(status: :succeeded)
               .where("created_at >= ?", start_date)
               .group("DATE_TRUNC('month', created_at)")
               .sum(:amount)
               .transform_keys { |date| date.strftime("%B %Y") }
      end

      def total_appointments_count(start_date: nil, end_date: nil)
        query = Appointment.all
        query = query.where("start_time >= ?", start_date) if start_date.present?
        query = query.where("start_time <= ?", end_date) if end_date.present?
        query.count
      end

      def appointments_by_status(start_date: nil, end_date: nil)
        query = Appointment.all
        query = query.where("start_time >= ?", start_date) if start_date.present?
        query = query.where("start_time <= ?", end_date) if end_date.present?
        query.group(:status).count
      end

      def top_providers_by_revenue(limit = 10)
        Payment.joins(:appointment)
               .where(status: :succeeded)
               .group("appointments.provider_id")
               .sum(:amount)
               .sort_by { |provider_id, revenue| -revenue }
               .first(limit)
               .map { |provider_id, revenue| { provider: User.find(provider_id), revenue: revenue } }
      end

      def top_services_by_bookings(limit = 10)
        Appointment.group(:service_id)
                   .count
                   .sort_by { |service_id, count| -count }
                   .first(limit)
                   .map { |service_id, count| { service: Service.find(service_id), bookings: count } }
      end

      def average_transaction_value
        total = total_platform_revenue
        count = Payment.where(status: :succeeded).count
        count.zero? ? 0 : (total.to_f / count).round(2)
      end

      def payment_success_rate
        total = Payment.count
        return 0 if total.zero?

        succeeded = Payment.where(status: :succeeded).count
        ((succeeded.to_f / total) * 100).round(2)
      end
    end
  end
end
