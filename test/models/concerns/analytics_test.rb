require "test_helper"

class AnalyticsTest < ActiveSupport::TestCase
  setup do
    @provider = users(:provider_user)
    @patient1 = users(:patient_user)
    @patient2 = users(:patient_user_two)
    @service = services(:coaching)

    # Create appointments with payments for testing analytics
    @appointment1 = Appointment.create!(
      patient: @patient1,
      provider: @provider,
      service: @service,
      start_time: 5.days.ago,
      end_time: 5.days.ago + 1.hour,
      status: :completed
    )

    @payment1 = Payment.create!(
      payer: @patient1,
      appointment: @appointment1,
      amount: 150.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_analytics_1",
      paid_at: 5.days.ago
    )

    @appointment2 = Appointment.create!(
      patient: @patient2,
      provider: @provider,
      service: @service,
      start_time: 3.days.ago,
      end_time: 3.days.ago + 1.hour,
      status: :completed
    )

    @payment2 = Payment.create!(
      payer: @patient2,
      appointment: @appointment2,
      amount: 200.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_analytics_2",
      paid_at: 3.days.ago
    )

    @appointment3 = Appointment.create!(
      patient: @patient1,
      provider: @provider,
      service: @service,
      start_time: 1.day.ago,
      end_time: 1.day.ago + 1.hour,
      status: :scheduled
    )

    @payment3 = Payment.create!(
      payer: @patient1,
      appointment: @appointment3,
      amount: 150.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_analytics_3",
      paid_at: 1.day.ago
    )
  end

  # ===== TOTAL REVENUE TESTS =====

  test "should calculate total revenue for all time" do
    total_revenue = @provider.total_revenue

    assert_equal 500.00, total_revenue
  end

  test "should calculate total revenue within date range" do
    revenue = @provider.total_revenue(start_date: 6.days.ago, end_date: 4.days.ago)

    assert_equal 150.00, revenue
  end

  test "should return zero revenue when no payments in date range" do
    revenue = @provider.total_revenue(start_date: 30.days.ago, end_date: 10.days.ago)

    assert_equal 0.00, revenue
  end

  # ===== APPOINTMENT COUNT TESTS =====

  test "should count total appointments for all time" do
    count = @provider.total_appointments

    assert_equal 3, count
  end

  test "should count appointments within date range" do
    count = @provider.total_appointments(start_date: 6.days.ago, end_date: 2.days.ago)

    assert_equal 2, count
  end

  test "should count appointments by status" do
    completed_count = @provider.appointments_by_status(:completed)
    scheduled_count = @provider.appointments_by_status(:scheduled)

    assert_equal 2, completed_count
    assert_equal 1, scheduled_count
  end

  # ===== UNIQUE CLIENTS/PATIENTS TESTS =====

  test "should count unique patients for all time" do
    count = @provider.unique_patients_count

    assert_equal 2, count
  end

  test "should count unique patients within date range" do
    count = @provider.unique_patients_count(start_date: 6.days.ago, end_date: 4.days.ago)

    assert_equal 1, count
  end

  # ===== APPOINTMENT STATUS BREAKDOWN TESTS =====

  test "should provide appointment status breakdown" do
    breakdown = @provider.appointment_status_breakdown

    assert_equal 2, breakdown[:completed]
    assert_equal 1, breakdown[:scheduled]
    assert_equal 0, breakdown[:cancelled_by_patient]
    assert_equal 0, breakdown[:cancelled_by_provider]
  end

  test "should provide appointment status breakdown within date range" do
    breakdown = @provider.appointment_status_breakdown(start_date: 6.days.ago, end_date: 2.days.ago)

    assert_equal 2, breakdown[:completed]
    assert_equal 0, breakdown[:scheduled]
  end

  # ===== REVENUE TRENDS TESTS =====

  test "should calculate revenue by month" do
    revenue_by_month = @provider.revenue_by_month
    current_month_key = Time.current.strftime("%Y-%m")

    assert revenue_by_month.key?(current_month_key)
    assert_equal 500.00, revenue_by_month[current_month_key]
  end

  test "should calculate revenue by week" do
    revenue_by_week = @provider.revenue_by_week
    current_week_key = Time.current.strftime("%Y-W%W")

    assert revenue_by_week.key?(current_week_key)
    assert_equal 500.00, revenue_by_week[current_week_key]
  end

  # ===== TOP SERVICES TESTS =====

  test "should list top services by revenue" do
    top_services = @provider.top_services_by_revenue(limit: 5)

    assert_equal 1, top_services.length
    assert_equal @service.id, top_services.first[:service_id]
    assert_equal @service.name, top_services.first[:service_name]
    assert_equal 500.00, top_services.first[:revenue]
    assert_equal 3, top_services.first[:appointments_count]
  end

  test "should respect limit parameter for top services" do
    top_services = @provider.top_services_by_revenue(limit: 1)

    assert_equal 1, top_services.length
  end

  # ===== AVERAGE SESSION PRICE TESTS =====

  test "should calculate average session price" do
    avg_price = @provider.average_session_price

    assert_in_delta 166.67, avg_price, 0.01
  end

  test "should calculate average session price within date range" do
    avg_price = @provider.average_session_price(start_date: 6.days.ago, end_date: 4.days.ago)

    assert_equal 150.00, avg_price
  end

  test "should return zero for average session price when no payments" do
    new_provider = User.create!(
      email: "newprovider@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "New",
      last_name: "Provider",
      role: :provider
    )

    avg_price = new_provider.average_session_price

    assert_equal 0.00, avg_price
  end
end
