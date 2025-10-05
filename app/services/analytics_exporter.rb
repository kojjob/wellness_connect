# frozen_string_literal: true

require 'csv'

# Service for exporting analytics data to CSV format
class AnalyticsExporter
  def initialize(user, start_date: nil, end_date: nil)
    @user = user
    @start_date = start_date
    @end_date = end_date
    @date_range_options = { start_date: @start_date, end_date: @end_date }
  end

  # Export provider revenue analytics to CSV
  def export_provider_revenue_csv
    CSV.generate(headers: true) do |csv|
      # Headers
      csv << [
        'Provider Name',
        'Total Revenue',
        'Total Appointments',
        'Completed Appointments',
        'Average Revenue per Appointment',
        'Completion Rate (%)',
        'Cancellation Rate (%)',
        'No Show Rate (%)',
        'Export Date',
        'Date Range'
      ]

      # Data row
      csv << [
        @user.full_name,
        format_currency(@user.total_revenue(**@date_range_options)),
        @user.total_appointments_count(**@date_range_options),
        @user.completed_appointments_count(**@date_range_options),
        format_currency(@user.average_revenue_per_appointment),
        @user.completion_rate.round(2),
        @user.cancellation_rate.round(2),
        @user.no_show_rate.round(2),
        Time.current.strftime("%Y-%m-%d %H:%M"),
        date_range_label
      ]

      # Revenue by service breakdown
      csv << [] # Empty row
      csv << ['Revenue by Service']
      csv << ['Service Name', 'Revenue']

      @user.revenue_by_service(**@date_range_options).each do |service_name, revenue|
        csv << [service_name, format_currency(revenue)]
      end

      # Revenue by month breakdown
      csv << [] # Empty row
      csv << ['Revenue by Month']
      csv << ['Month', 'Revenue']

      @user.revenue_by_month(6).each do |month, revenue|
        csv << [month, format_currency(revenue)]
      end

      # Appointments by status breakdown
      csv << [] # Empty row
      csv << ['Appointments by Status']
      csv << ['Status', 'Count']

      @user.appointments_by_status.each do |status, count|
        csv << [status.titleize, count]
      end

      # Peak booking hours
      csv << [] # Empty row
      csv << ['Peak Booking Hours']
      csv << ['Hour', 'Bookings']

      @user.peak_booking_hours.each do |hour, count|
        csv << [format_hour(hour), count]
      end
    end
  end

  # Export patient/client analytics to CSV
  def export_patient_analytics_csv
    CSV.generate(headers: true) do |csv|
      # Headers
      csv << [
        'Client Name',
        'Total Spent',
        'Total Sessions',
        'Completed Sessions',
        'Upcoming Sessions',
        'Average Spending per Session',
        'Export Date',
        'Date Range'
      ]

      # Data row
      csv << [
        @user.full_name,
        format_currency(@user.total_spent(**@date_range_options)),
        @user.total_sessions_count(**@date_range_options),
        @user.completed_sessions_count(**@date_range_options),
        @user.upcoming_sessions_count(**@date_range_options),
        format_currency(@user.average_spending_per_session),
        Time.current.strftime("%Y-%m-%d %H:%M"),
        date_range_label
      ]

      # Spending by month breakdown
      csv << [] # Empty row
      csv << ['Spending by Month']
      csv << ['Month', 'Amount']

      @user.spending_by_month(6).each do |month, amount|
        csv << [month, format_currency(amount)]
      end

      # Favorite providers
      csv << [] # Empty row
      csv << ['Most Booked Providers']
      csv << ['Provider Name', 'Sessions']

      @user.favorite_providers(10).each do |data|
        csv << [data[:provider].full_name, data[:sessions]]
      end
    end
  end

  # Export platform-wide analytics to CSV (for admins)
  def self.export_platform_analytics_csv(start_date: nil, end_date: nil)
    date_range_options = { start_date: start_date, end_date: end_date }

    CSV.generate(headers: true) do |csv|
      # Platform overview
      csv << ['Platform Analytics Export']
      csv << ['Export Date', Time.current.strftime("%Y-%m-%d %H:%M")]
      csv << ['Date Range', date_range_label(start_date, end_date)]
      csv << []

      # User statistics
      csv << ['User Statistics']
      csv << ['Metric', 'Count']
      csv << ['Total Users', User.total_users_count(**date_range_options)]
      csv << ['Total Providers', User.total_providers_count(**date_range_options)]
      csv << ['Total Patients', User.total_patients_count(**date_range_options)]
      csv << []

      # Revenue statistics
      csv << ['Revenue Statistics']
      csv << ['Metric', 'Value']
      csv << ['Total Revenue', format_currency_static(User.total_platform_revenue(**date_range_options))]
      csv << ['Average Transaction Value', format_currency_static(User.average_transaction_value)]
      csv << ['Payment Success Rate (%)', User.payment_success_rate.round(2)]
      csv << []

      # Appointment statistics
      csv << ['Appointment Statistics']
      csv << ['Metric', 'Count']
      csv << ['Total Appointments', User.total_appointments_count(**date_range_options)]
      csv << []

      # Appointments by status
      csv << ['Appointments by Status']
      csv << ['Status', 'Count']
      User.appointments_by_status(**date_range_options).each do |status, count|
        csv << [status.titleize, count]
      end
      csv << []

      # User growth by month
      csv << ['User Growth by Month']
      csv << ['Month', 'New Users']
      User.users_growth_by_month(6).each do |month, count|
        csv << [month, count]
      end
      csv << []

      # Revenue by month
      csv << ['Revenue by Month']
      csv << ['Month', 'Revenue']
      User.platform_revenue_by_month(6).each do |month, revenue|
        csv << [month, format_currency_static(revenue)]
      end
      csv << []

      # Top providers by revenue
      csv << ['Top Providers by Revenue']
      csv << ['Rank', 'Provider Name', 'Revenue']
      User.top_providers_by_revenue(10).each_with_index do |data, index|
        csv << [index + 1, data[:provider].full_name, format_currency_static(data[:revenue])]
      end
      csv << []

      # Top services by bookings
      csv << ['Top Services by Bookings']
      csv << ['Rank', 'Service Name', 'Bookings']
      User.top_services_by_bookings(10).each_with_index do |data, index|
        csv << [index + 1, data[:service].name, data[:bookings]]
      end
    end
  end

  private

  def format_currency(amount_in_cents)
    return '$0.00' if amount_in_cents.nil? || amount_in_cents.zero?
    "$#{(amount_in_cents / 100.0).round(2)}"
  end

  def self.format_currency_static(amount_in_cents)
    return '$0.00' if amount_in_cents.nil? || amount_in_cents.zero?
    "$#{(amount_in_cents / 100.0).round(2)}"
  end

  def format_hour(hour)
    time = Time.parse("#{hour}:00")
    time.strftime("%I:00 %p")
  end

  def date_range_label
    return 'All Time' if @start_date.nil? && @end_date.nil?
    return "Since #{@start_date.strftime('%Y-%m-%d')}" if @end_date.nil?
    return "Until #{@end_date.strftime('%Y-%m-%d')}" if @start_date.nil?

    "#{@start_date.strftime('%Y-%m-%d')} to #{@end_date.strftime('%Y-%m-%d')}"
  end

  def self.date_range_label(start_date, end_date)
    return 'All Time' if start_date.nil? && end_date.nil?
    return "Since #{start_date.strftime('%Y-%m-%d')}" if end_date.nil?
    return "Until #{end_date.strftime('%Y-%m-%d')}" if start_date.nil?

    "#{start_date.strftime('%Y-%m-%d')} to #{end_date.strftime('%Y-%m-%d')}"
  end
end
