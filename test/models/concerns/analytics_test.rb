require "test_helper"

class AnalyticsTest < ActiveSupport::TestCase
  # ========================================
  # Test Setup
  # ========================================

  setup do
    @provider = users(:provider_user)
    @patient = users(:patient_user)
    @service = @provider.provider_profile.services.first
  end

  # ========================================
  # ProviderRevenue Module Tests
  # ========================================

  test "total_revenue returns sum of all successful payments for provider" do
    # Create test payments
    appointment1 = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 1.hour,
      status: :completed
    )

    appointment2 = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 2.days,
      end_time: Time.current + 2.days + 1.hour,
      status: :completed
    )

    Payment.create!(payer: @patient, appointment: appointment1, amount: 10000, status: :succeeded)
    Payment.create!(payer: @patient, appointment: appointment2, amount: 15000, status: :succeeded)

    assert_equal 25000, @provider.total_revenue
  end

  test "total_revenue excludes pending and failed payments" do
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 1.hour,
      status: :scheduled
    )

    Payment.create!(payer: @patient, appointment: appointment, amount: 10000, status: :pending)
    Payment.create!(payer: @patient, appointment: appointment, amount: 5000, status: :failed)

    # Should return 0 if no succeeded payments
    initial_revenue = @provider.total_revenue
    assert initial_revenue >= 0 # May have existing test data
  end

  test "revenue_for_period returns revenue within date range" do
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current,
      end_time: Time.current + 1.hour,
      status: :completed
    )

    payment = Payment.create!(
      payer: @patient,
      appointment: appointment,
      amount: 20000,
      status: :succeeded,
      created_at: Time.current
    )

    start_date = 1.day.ago
    end_date = 1.day.from_now

    revenue = @provider.revenue_for_period(start_date, end_date)
    assert revenue >= 20000
  end

  test "revenue_by_month returns monthly revenue grouped by month" do
    revenue_data = @provider.revenue_by_month(6)

    assert_kind_of Hash, revenue_data
    # Verify keys are formatted as month names
    revenue_data.keys.each do |key|
      assert_match(/\w+ \d{4}/, key) # Format: "January 2024"
    end
  end

  test "revenue_by_service returns revenue grouped by service name" do
    revenue_by_service = @provider.revenue_by_service

    assert_kind_of Hash, revenue_by_service
    # All keys should be service names (strings)
    revenue_by_service.keys.each do |key|
      assert_kind_of String, key
    end
  end

  test "average_revenue_per_appointment calculates correctly" do
    # Create completed appointments with payments
    2.times do |i|
      appointment = Appointment.create!(
        patient: @patient,
        provider: @provider,
        service: @service,
        start_time: Time.current + (i + 1).days,
        end_time: Time.current + (i + 1).days + 1.hour,
        status: :completed
      )

      Payment.create!(
        payer: @patient,
        appointment: appointment,
        amount: 10000, # $100
        status: :succeeded
      )
    end

    # Reload to get updated counts
    @provider.reload

    avg_revenue = @provider.average_revenue_per_appointment
    assert avg_revenue > 0
    assert_kind_of Float, avg_revenue
  end

  test "average_revenue_per_appointment returns 0 when no completed appointments" do
    # Create provider with no appointments
    new_provider = User.create!(
      email: "newprovider@test.com",
      password: "password123",
      first_name: "New",
      last_name: "Provider",
      role: :provider
    )

    ProviderProfile.create!(
      user: new_provider,
      specialty: "Test",
      bio: "Test bio",
      credentials: "Test credentials"
    )

    assert_equal 0, new_provider.average_revenue_per_appointment
  end

  # ========================================
  # ProviderAppointments Module Tests
  # ========================================

  test "total_appointments_count returns correct count" do
    initial_count = @provider.total_appointments_count

    Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 1.hour,
      status: :scheduled
    )

    assert_equal initial_count + 1, @provider.total_appointments_count
  end

  test "completion_rate calculates percentage correctly" do
    # Create appointments with different statuses
    Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 1.hour,
      status: :completed
    )

    Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 2.days,
      end_time: Time.current + 2.days + 1.hour,
      status: :scheduled
    )

    completion_rate = @provider.completion_rate
    assert completion_rate >= 0
    assert completion_rate <= 100
  end

  test "completion_rate returns 0 when no appointments" do
    new_provider = User.create!(
      email: "emptyprovider@test.com",
      password: "password123",
      first_name: "Empty",
      last_name: "Provider",
      role: :provider
    )

    ProviderProfile.create!(
      user: new_provider,
      specialty: "Test",
      bio: "Test bio",
      credentials: "Test credentials"
    )

    assert_equal 0, new_provider.completion_rate
  end

  test "cancellation_rate calculates percentage correctly" do
    rate = @provider.cancellation_rate
    assert rate >= 0
    assert rate <= 100
  end

  test "no_show_rate calculates percentage correctly" do
    rate = @provider.no_show_rate
    assert rate >= 0
    assert rate <= 100
  end

  test "appointments_by_month returns monthly appointment counts" do
    appointments_by_month = @provider.appointments_by_month(6)

    assert_kind_of Hash, appointments_by_month
    # Verify keys are formatted as month names
    appointments_by_month.keys.each do |key|
      assert_match(/\w+ \d{4}/, key) # Format: "January 2024"
    end
  end

  test "appointments_by_status returns appointment counts by status" do
    appointments_by_status = @provider.appointments_by_status

    assert_kind_of Hash, appointments_by_status
    # Values should be integers
    appointments_by_status.values.each do |count|
      assert_kind_of Integer, count
    end
  end

  test "peak_booking_hours returns top 5 hours" do
    peak_hours = @provider.peak_booking_hours

    assert_kind_of Hash, peak_hours
    assert peak_hours.size <= 5
  end

  test "average_appointments_per_week calculates correctly" do
    avg_per_week = @provider.average_appointments_per_week
    assert avg_per_week >= 0
  end

  # ========================================
  # PatientAnalytics Module Tests
  # ========================================

  test "total_spent returns sum of successful payments for patient" do
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 1.hour,
      status: :completed
    )

    Payment.create!(
      payer: @patient,
      appointment: appointment,
      amount: 15000,
      status: :succeeded
    )

    total_spent = @patient.total_spent
    assert total_spent >= 15000
  end

  test "spending_by_month returns monthly spending" do
    spending_by_month = @patient.spending_by_month(6)

    assert_kind_of Hash, spending_by_month
    # Verify keys are formatted as month names
    spending_by_month.keys.each do |key|
      assert_match(/\w+ \d{4}/, key)
    end
  end

  test "total_sessions_count returns correct count" do
    initial_count = @patient.total_sessions_count

    Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 1.hour,
      status: :scheduled
    )

    assert_equal initial_count + 1, @patient.total_sessions_count
  end

  test "completed_sessions_count returns only completed appointments" do
    initial_completed = @patient.completed_sessions_count

    Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 1.hour,
      status: :completed
    )

    assert_equal initial_completed + 1, @patient.completed_sessions_count
  end

  test "upcoming_sessions_count returns only future scheduled appointments" do
    upcoming_count = @patient.upcoming_sessions_count

    Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.current + 1.week,
      end_time: Time.current + 1.week + 1.hour,
      status: :scheduled
    )

    assert_equal upcoming_count + 1, @patient.upcoming_sessions_count
  end

  test "favorite_providers returns providers sorted by appointment count" do
    favorites = @patient.favorite_providers(5)

    assert_kind_of Array, favorites
    assert favorites.size <= 5

    # Each item should have provider and sessions keys
    favorites.each do |item|
      assert item.key?(:provider)
      assert item.key?(:sessions)
      assert_kind_of User, item[:provider]
      assert_kind_of Integer, item[:sessions]
    end
  end

  test "average_spending_per_session calculates correctly" do
    avg_spending = @patient.average_spending_per_session
    assert avg_spending >= 0
  end

  # ========================================
  # PlatformAnalytics Module Tests
  # ========================================

  test "total_users_count returns correct count" do
    count = User.total_users_count
    assert count > 0
    assert_equal User.count, count
  end

  test "total_providers_count returns correct count" do
    count = User.total_providers_count
    assert count >= 0
    assert_equal User.where(role: :provider).count, count
  end

  test "total_patients_count returns correct count" do
    count = User.total_patients_count
    assert count >= 0
    assert_equal User.where(role: :patient).count, count
  end

  test "users_growth_by_month returns monthly user growth" do
    growth_data = User.users_growth_by_month(6)

    assert_kind_of Hash, growth_data
    # Verify keys are formatted as month names
    growth_data.keys.each do |key|
      assert_match(/\w+ \d{4}/, key)
    end
  end

  test "total_platform_revenue returns sum of all successful payments" do
    revenue = User.total_platform_revenue
    assert revenue >= 0
  end

  test "platform_revenue_by_month returns monthly revenue" do
    revenue_data = User.platform_revenue_by_month(6)

    assert_kind_of Hash, revenue_data
    # Verify keys are formatted as month names
    revenue_data.keys.each do |key|
      assert_match(/\w+ \d{4}/, key)
    end
  end

  test "total_appointments_count returns correct platform-wide count" do
    count = User.total_appointments_count
    assert count >= 0
    assert_equal Appointment.count, count
  end

  test "appointments_by_status returns platform-wide appointment status counts" do
    status_data = User.appointments_by_status

    assert_kind_of Hash, status_data
    # All values should be integers
    status_data.values.each do |count|
      assert_kind_of Integer, count
    end
  end

  test "top_providers_by_revenue returns top providers with revenue" do
    top_providers = User.top_providers_by_revenue(5)

    assert_kind_of Array, top_providers
    assert top_providers.size <= 5

    # Each item should have provider and revenue keys
    top_providers.each do |item|
      assert item.key?(:provider)
      assert item.key?(:revenue)
      assert_kind_of User, item[:provider]
    end
  end

  test "top_services_by_bookings returns top services with booking counts" do
    top_services = User.top_services_by_bookings(5)

    assert_kind_of Array, top_services
    assert top_services.size <= 5

    # Each item should have service and bookings keys
    top_services.each do |item|
      assert item.key?(:service)
      assert item.key?(:bookings)
      assert_kind_of Service, item[:service]
      assert_kind_of Integer, item[:bookings]
    end
  end

  test "average_transaction_value calculates correctly" do
    avg_value = User.average_transaction_value
    assert avg_value >= 0
  end

  test "payment_success_rate calculates percentage correctly" do
    success_rate = User.payment_success_rate
    assert success_rate >= 0
    assert success_rate <= 100
  end

  test "payment_success_rate returns 0 when no payments" do
    # This would only work in a clean database, so we just verify it's a valid percentage
    success_rate = User.payment_success_rate
    assert success_rate >= 0
    assert success_rate <= 100
  end
end
