require "test_helper"

class AnalyticsTest < ActiveSupport::TestCase
  setup do
    @provider = users(:provider_user)
    @patient1 = users(:patient_user)
    @patient2 = users(:patient_user_two)
    @service = services(:service_one)

    # Clean up any existing test data
    @provider.appointments_as_provider.destroy_all
    Payment.where(payer: [@patient1, @patient2]).destroy_all

    # Create test appointments and payments - all within current month
    current_month_start = Time.current.beginning_of_month

    @appointment1 = Appointment.create!(
      patient: @patient1,
      provider: @provider,
      service: @service,
      start_time: current_month_start + 5.days,
      end_time: current_month_start + 5.days + 1.hour,
      status: :completed
    )
    @payment1 = Payment.create!(
      payer: @patient1,
      appointment: @appointment1,
      amount: 150.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_analytics_1",
      paid_at: current_month_start + 5.days
    )

    @appointment2 = Appointment.create!(
      patient: @patient2,
      provider: @provider,
      service: @service,
      start_time: current_month_start + 10.days,
      end_time: current_month_start + 10.days + 1.hour,
      status: :completed
    )
    @payment2 = Payment.create!(
      payer: @patient2,
      appointment: @appointment2,
      amount: 200.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_analytics_2",
      paid_at: current_month_start + 10.days
    )

    @appointment3 = Appointment.create!(
      patient: @patient1,
      provider: @provider,
      service: @service,
      start_time: current_month_start + 15.days,
      end_time: current_month_start + 15.days + 1.hour,
      status: :scheduled
    )
    @payment3 = Payment.create!(
      payer: @patient1,
      appointment: @appointment3,
      amount: 150.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_analytics_3",
      paid_at: current_month_start + 15.days
    )
  end

  # Revenue Analytics Tests
  test "should calculate total revenue for all time" do
    total = @provider.total_revenue
    assert_equal 500.00, total
  end

  test "should calculate total revenue with date range" do
    current_month_start = Time.current.beginning_of_month
    start_date = current_month_start + 8.days
    end_date = current_month_start + 12.days

    total = @provider.total_revenue(start_date: start_date, end_date: end_date)
    assert_equal 200.00, total # Only payment2 (200) is within the date range
  end

  test "should calculate total revenue with start date only" do
    current_month_start = Time.current.beginning_of_month
    start_date = current_month_start + 12.days

    total = @provider.total_revenue(start_date: start_date)
    assert_equal 150.00, total # only payment3
  end

  test "should calculate total revenue with end date only" do
    current_month_start = Time.current.beginning_of_month
    end_date = current_month_start + 12.days

    total = @provider.total_revenue(end_date: end_date)
    assert_equal 350.00, total # payment1 + payment2
  end

  test "should exclude failed payments from revenue" do
    # Create a failed payment
    current_month_start = Time.current.beginning_of_month

    failed_appointment = Appointment.create!(
      patient: @patient1,
      provider: @provider,
      service: @service,
      start_time: current_month_start + 12.days,
      end_time: current_month_start + 12.days + 1.hour,
      status: :completed
    )
    Payment.create!(
      payer: @patient1,
      appointment: failed_appointment,
      amount: 100.00,
      currency: "usd",
      status: :failed,
      stripe_payment_intent_id: "pi_test_failed",
      paid_at: current_month_start + 12.days
    )

    total = @provider.total_revenue
    assert_equal 500.00, total # Should still be 500, not 600
  end

  test "should calculate average session price" do
    avg = @provider.average_session_price
    assert_in_delta 166.67, avg, 0.01 # (150 + 200 + 150) / 3
  end

  test "should return 0 for average session price with no payments" do
    # Destroy all appointments and payments for this provider
    Payment.joins(appointment: :provider)
      .where(appointments: { provider_id: @provider.id })
      .destroy_all
    @provider.appointments_as_provider.destroy_all

    # Reload provider to clear any cached associations
    @provider.reload

    avg = @provider.average_session_price
    assert_equal 0.0, avg
  end

  test "should calculate revenue by month" do
    revenue_by_month = @provider.revenue_by_month
    current_month_key = Time.current.strftime("%Y-%m")

    assert revenue_by_month.key?(current_month_key)
    assert_equal 500.00, revenue_by_month[current_month_key]
  end

  test "should calculate revenue by week" do
    # Create fresh payments all within the current week
    current_week_start = Time.current.beginning_of_week
    current_week_key = current_week_start.strftime("%Y-W%U")

    # Clean up existing test data
    Payment.joins(appointment: :provider)
      .where(appointments: { provider_id: @provider.id })
      .destroy_all
    @provider.appointments_as_provider.destroy_all

    # Create appointments and payments within current week
    service = @provider.provider_profile.services.first

    apt1 = Appointment.create!(
      patient: @patient1,
      provider: @provider,
      service: service,
      start_time: current_week_start + 1.day,
      end_time: current_week_start + 1.day + 1.hour,
      status: :completed
    )
    Payment.create!(
      payer: @patient1,
      appointment: apt1,
      amount: 150.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_week_1",
      paid_at: current_week_start + 1.day
    )

    apt2 = Appointment.create!(
      patient: @patient2,
      provider: @provider,
      service: service,
      start_time: current_week_start + 3.days,
      end_time: current_week_start + 3.days + 1.hour,
      status: :completed
    )
    Payment.create!(
      payer: @patient2,
      appointment: apt2,
      amount: 200.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_week_2",
      paid_at: current_week_start + 3.days
    )

    revenue_by_week = @provider.revenue_by_week

    assert revenue_by_week.key?(current_week_key), "Expected week key #{current_week_key} not found in #{revenue_by_week.keys}"
    assert_equal 350.00, revenue_by_week[current_week_key]
  end

  # Appointment Analytics Tests
  test "should calculate total appointments" do
    total = @provider.total_appointments
    assert_equal 3, total
  end

  test "should calculate total appointments with date range" do
    current_month_start = Time.current.beginning_of_month
    start_date = current_month_start + 8.days
    end_date = current_month_start + 12.days

    total = @provider.total_appointments(start_date: start_date, end_date: end_date)
    assert_equal 1, total # Only appointment2 is within the date range
  end

  test "should calculate appointments by status" do
    count = @provider.appointments_by_status(:completed)
    assert_equal 2, count
  end

  test "should calculate appointment status breakdown" do
    breakdown = @provider.appointment_status_breakdown

    assert_equal 2, breakdown[:completed]
    assert_equal 1, breakdown[:scheduled]
    assert_equal 0, breakdown[:cancelled_by_patient]
  end

  # Patient Analytics Tests
  test "should count unique patients" do
    count = @provider.unique_patients_count
    assert_equal 2, count
  end

  test "should count unique patients with date range" do
    current_month_start = Time.current.beginning_of_month
    start_date = current_month_start + 8.days
    end_date = current_month_start + 12.days

    count = @provider.unique_patients_count(start_date: start_date, end_date: end_date)
    assert_equal 1, count # Only appointment2 (patient2) is within the date range
  end

  # Service Analytics Tests
  test "should rank top services by revenue" do
    # Create another service with different revenue
    service2 = Service.create!(
      provider_profile: @provider.provider_profile,
      name: "Premium Consultation",
      description: "Premium service",
      duration_minutes: 90,
      price: 250.00,
      is_active: true
    )

    appointment4 = Appointment.create!(
      patient: @patient2,
      provider: @provider,
      service: service2,
      start_time: 2.days.ago,
      end_time: 2.days.ago + 1.5.hours,
      status: :completed
    )
    Payment.create!(
      payer: @patient2,
      appointment: appointment4,
      amount: 250.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_analytics_4",
      paid_at: 2.days.ago
    )

    top_services = @provider.top_services_by_revenue(limit: 2)

    assert_equal 2, top_services.length
    assert_equal 500.00, top_services.first[:revenue]
    assert_equal 250.00, top_services.second[:revenue]
  end

  test "should limit top services results" do
    top_services = @provider.top_services_by_revenue(limit: 1)
    assert_equal 1, top_services.length
  end
end
