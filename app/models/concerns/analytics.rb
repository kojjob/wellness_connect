# frozen_string_literal: true

# Analytics module provides business intelligence and metrics methods for providers
# Tracks revenue, appointments, clients, and performance analytics
module Analytics
  extend ActiveSupport::Concern

  # ===== REVENUE ANALYTICS =====

  # Calculate total revenue for provider within optional date range
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [Float] Total revenue in dollars
  def total_revenue(start_date: nil, end_date: nil)
    payments_scope = successful_payments
    payments_scope = apply_date_range(payments_scope, :paid_at, start_date, end_date)
    payments_scope.sum(:amount).to_f
  end

  # Calculate average price per session within optional date range
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [Float] Average session price in dollars
  def average_session_price(start_date: nil, end_date: nil)
    payments_scope = successful_payments
    payments_scope = apply_date_range(payments_scope, :paid_at, start_date, end_date)

    count = payments_scope.count
    return 0.0 if count.zero?

    (payments_scope.sum(:amount) / count).to_f
  end

  # Calculate revenue grouped by month
  # @param months_back [Integer] Number of months to look back (default: 12)
  # @return [Hash] Revenue by month key (YYYY-MM)
  def revenue_by_month(months_back: 12)
    start_date = months_back.months.ago.beginning_of_month

    successful_payments
      .where("paid_at >= ?", start_date)
      .group_by { |payment| payment.paid_at.strftime("%Y-%m") }
      .transform_values { |payments| payments.sum(&:amount).to_f }
  end

  # Calculate revenue grouped by week
  # @param weeks_back [Integer] Number of weeks to look back (default: 12)
  # @return [Hash] Revenue by week key (YYYY-WWW)
  def revenue_by_week(weeks_back: 12)
    start_date = weeks_back.weeks.ago.beginning_of_week

    successful_payments
      .where("paid_at >= ?", start_date)
      .group_by { |payment| payment.paid_at.strftime("%Y-W%W") }
      .transform_values { |payments| payments.sum(&:amount).to_f }
  end

  # ===== APPOINTMENT ANALYTICS =====

  # Count total appointments for provider within optional date range
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [Integer] Total appointment count
  def total_appointments(start_date: nil, end_date: nil)
    scope = appointments_as_provider
    scope = apply_date_range(scope, :start_time, start_date, end_date)
    scope.count
  end

  # Count appointments by status
  # @param status [Symbol, String] Appointment status (scheduled, completed, cancelled_by_patient, cancelled_by_provider)
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [Integer] Count of appointments with given status
  def appointments_by_status(status, start_date: nil, end_date: nil)
    scope = appointments_as_provider.where(status: status)
    scope = apply_date_range(scope, :start_time, start_date, end_date)
    scope.count
  end

  # Provide breakdown of appointments by all statuses
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [Hash] Status counts hash (e.g., { completed: 10, scheduled: 5, ... })
  def appointment_status_breakdown(start_date: nil, end_date: nil)
    scope = appointments_as_provider
    scope = apply_date_range(scope, :start_time, start_date, end_date)

    # Initialize all statuses with 0
    breakdown = {
      scheduled: 0,
      completed: 0,
      cancelled_by_patient: 0,
      cancelled_by_provider: 0,
      no_show: 0
    }

    # Count appointments by status
    scope.group(:status).count.each do |status, count|
      breakdown[status.to_sym] = count
    end

    breakdown
  end

  # ===== CLIENT/PATIENT ANALYTICS =====

  # Count unique patients/clients within optional date range
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [Integer] Count of unique patients
  def unique_patients_count(start_date: nil, end_date: nil)
    scope = appointments_as_provider
    scope = apply_date_range(scope, :start_time, start_date, end_date)
    scope.distinct.count(:patient_id)
  end

  # ===== SERVICE ANALYTICS =====

  # List top services by revenue
  # @param limit [Integer] Number of top services to return (default: 5)
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [Array<Hash>] Array of hashes with service data and metrics
  def top_services_by_revenue(limit: 5, start_date: nil, end_date: nil)
    appointments_scope = appointments_as_provider
    appointments_scope = apply_date_range(appointments_scope, :start_time, start_date, end_date)

    # Group appointments by service and calculate metrics
    service_data = appointments_scope
      .joins(:payment)
      .where(payments: { status: :succeeded })
      .group(:service_id)
      .select(
        "service_id",
        "SUM(payments.amount) as total_revenue",
        "COUNT(appointments.id) as appointments_count"
      )
      .order("total_revenue DESC")
      .limit(limit)

    # Build result array with service details
    service_data.map do |data|
      service = Service.find(data.service_id)
      {
        service_id: data.service_id,
        service_name: service.name,
        revenue: data.total_revenue.to_f,
        appointments_count: data.appointments_count
      }
    end
  end

  private

  # Helper method to get successful payments for the provider
  # @return [ActiveRecord::Relation] Payments with succeeded status
  def successful_payments
    Payment.joins(appointment: :provider)
      .where(appointments: { provider_id: id }, status: :succeeded)
  end

  # Helper method to apply date range filter to a scope
  # @param scope [ActiveRecord::Relation] The scope to filter
  # @param date_column [Symbol] Column name to filter on
  # @param start_date [Date, DateTime, nil] Start of date range
  # @param end_date [Date, DateTime, nil] End of date range
  # @return [ActiveRecord::Relation] Filtered scope
  def apply_date_range(scope, date_column, start_date, end_date)
    scope = scope.where("#{date_column} >= ?", start_date) if start_date.present?
    scope = scope.where("#{date_column} <= ?", end_date) if end_date.present?
    scope
  end
end
