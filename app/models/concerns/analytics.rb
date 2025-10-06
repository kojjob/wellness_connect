module Analytics
  extend ActiveSupport::Concern

  # Revenue Analytics Methods

  # Calculate total revenue for the provider
  # @param start_date [Date, nil] Optional start date filter
  # @param end_date [Date, nil] Optional end date filter
  # @return [Float] Total revenue amount
  def total_revenue(start_date: nil, end_date: nil)
    payments_scope = successful_payments
    payments_scope = apply_date_range(payments_scope, :paid_at, start_date, end_date)
    payments_scope.sum(:amount).to_f
  end

  # Calculate average price per session
  # @return [Float] Average session price
  def average_session_price
    payments = successful_payments
    return 0.0 if payments.empty?

    (payments.sum(:amount) / payments.count).to_f
  end

  # Calculate revenue grouped by month
  # @param months_back [Integer] Number of months to look back
  # @return [Hash] Hash with month keys (YYYY-MM) and revenue values
  def revenue_by_month(months_back: 12)
    start_date = months_back.months.ago.beginning_of_month
    successful_payments
      .where("paid_at >= ?", start_date)
      .group_by { |payment| payment.paid_at.strftime("%Y-%m") }
      .transform_values { |payments| payments.sum(&:amount).to_f }
  end

  # Calculate revenue grouped by week
  # @param weeks_back [Integer] Number of weeks to look back
  # @return [Hash] Hash with week keys (YYYY-W##) and revenue values
  def revenue_by_week(weeks_back: 12)
    start_date = weeks_back.weeks.ago.beginning_of_week
    successful_payments
      .where("paid_at >= ?", start_date)
      .group_by { |payment| payment.paid_at.strftime("%Y-W%U") }
      .transform_values { |payments| payments.sum(&:amount).to_f }
  end

  # Appointment Analytics Methods

  # Calculate total number of appointments
  # @param start_date [Date, nil] Optional start date filter
  # @param end_date [Date, nil] Optional end date filter
  # @return [Integer] Total appointment count
  def total_appointments(start_date: nil, end_date: nil)
    appointments_scope = appointments_as_provider
    appointments_scope = apply_date_range(appointments_scope, :start_time, start_date, end_date)
    appointments_scope.count
  end

  # Count appointments by status
  # @param status [Symbol] Appointment status
  # @return [Integer] Count of appointments with given status
  def appointments_by_status(status)
    appointments_as_provider.where(status: status).count
  end

  # Get breakdown of appointments by all statuses
  # @return [Hash] Hash with status symbol keys and count values
  def appointment_status_breakdown
    Appointment.statuses.keys.map(&:to_sym).index_with do |status|
      appointments_by_status(status)
    end
  end

  # Patient Analytics Methods

  # Count unique patients
  # @param start_date [Date, nil] Optional start date filter
  # @param end_date [Date, nil] Optional end date filter
  # @return [Integer] Count of unique patients
  def unique_patients_count(start_date: nil, end_date: nil)
    appointments_scope = appointments_as_provider
    appointments_scope = apply_date_range(appointments_scope, :start_time, start_date, end_date)
    appointments_scope.distinct.count(:patient_id)
  end

  # Service Analytics Methods

  # Get top services by revenue
  # @param limit [Integer] Number of top services to return
  # @return [Array<Hash>] Array of hashes with service_id, service_name, and revenue
  def top_services_by_revenue(limit: 5)
    Payment.joins(appointment: [ :service, :provider ])
      .where(appointments: { provider_id: id }, status: :succeeded)
      .group("services.id", "services.name")
      .select("services.id as service_id, services.name as service_name, SUM(payments.amount) as revenue")
      .order("revenue DESC")
      .limit(limit)
      .map { |result| { service_id: result.service_id, service_name: result.service_name, revenue: result.revenue.to_f } }
  end

  private

  # Get all successful payments for this provider
  # @return [ActiveRecord::Relation] Successful payments
  def successful_payments
    Payment.joins(appointment: :provider)
      .where(appointments: { provider_id: id }, status: :succeeded)
  end

  # Apply date range filter to a scope
  # @param scope [ActiveRecord::Relation] The scope to filter
  # @param date_column [Symbol] The date column to filter on
  # @param start_date [Date, nil] Optional start date
  # @param end_date [Date, nil] Optional end date
  # @return [ActiveRecord::Relation] Filtered scope
  def apply_date_range(scope, date_column, start_date, end_date)
    scope = scope.where("#{date_column} >= ?", start_date) if start_date.present?
    scope = scope.where("#{date_column} <= ?", end_date) if end_date.present?
    scope
  end
end
