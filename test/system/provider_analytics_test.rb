require "application_system_test_case"

class ProviderAnalyticsTest < ApplicationSystemTestCase
  setup do
    @provider = users(:provider_user)
    @patient = users(:patient_user)
    @service = services(:service_one)

    # Clean up existing test data
    @provider.appointments_as_provider.destroy_all
    Payment.where(payer: @patient).destroy_all

    # Create test data for analytics
    current_month_start = Time.current.beginning_of_month

    # Completed appointment with payment
    appointment1 = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: current_month_start + 5.days,
      end_time: current_month_start + 5.days + 1.hour,
      status: :completed
    )
    Payment.create!(
      payer: @patient,
      appointment: appointment1,
      amount: 150.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_system_1",
      paid_at: current_month_start + 5.days
    )

    # Another completed appointment
    appointment2 = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: current_month_start + 10.days,
      end_time: current_month_start + 10.days + 1.hour,
      status: :completed
    )
    Payment.create!(
      payer: @patient,
      appointment: appointment2,
      amount: 200.00,
      currency: "usd",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_system_2",
      paid_at: current_month_start + 10.days
    )

    sign_in @provider
  end

  test "provider can access analytics dashboard" do
    visit provider_analytics_path

    assert_selector "h1", text: "Analytics Dashboard"
  end

  test "analytics dashboard displays key metrics cards" do
    visit provider_analytics_path

    # Check for metric cards
    assert_text "Total Revenue"
    assert_text "$350.00" # 150 + 200

    assert_text "Avg Session Price"
    assert_text "$175.00" # (150 + 200) / 2

    assert_text "Total Sessions"
    assert_text "2"

    assert_text "Unique Clients"
    assert_text "1"
  end

  test "analytics dashboard displays revenue charts" do
    visit provider_analytics_path

    # Check for chart sections
    assert_selector "h3", text: "Revenue by Month (Last 6 Months)"
    assert_selector "h3", text: "Revenue by Week (Last 8 Weeks)"

    # Check for canvas elements with Stimulus controller
    assert_selector "canvas[data-controller='analytics-chart']", count: 2
  end

  test "analytics dashboard displays session status breakdown" do
    visit provider_analytics_path

    assert_selector "h3", text: "Session Status Breakdown"
    assert_text "Completed"
    assert_text "Scheduled"
  end

  test "analytics dashboard displays top services" do
    visit provider_analytics_path

    assert_selector "h3", text: "Top Services by Revenue"
    # Should show the service name and revenue
    assert_text @service.name
    assert_text "$350.00"
  end

  test "provider can filter analytics by date range" do
    visit provider_analytics_path

    current_month_start = Time.current.beginning_of_month

    # Fill in date range filter
    fill_in "start_date", with: (current_month_start + 1.day).to_date
    fill_in "end_date", with: (current_month_start + 7.days).to_date

    click_button "Apply Filter"

    # Should show filtered results
    within "#filtered-results" do
      assert_text "Filtered Revenue"
      assert_text "$150.00" # Only the first payment in range
    end
  end

  test "provider can clear date range filter" do
    visit provider_analytics_path

    current_month_start = Time.current.beginning_of_month

    # Apply filter
    fill_in "start_date", with: (current_month_start + 1.day).to_date
    fill_in "end_date", with: (current_month_start + 7.days).to_date
    click_button "Apply Filter"

    # Clear filter
    click_link "Clear Filter"

    # Should return to unfiltered view
    assert_current_path provider_analytics_path
    assert_no_selector "#filtered-results"
  end

  test "patient cannot access provider analytics dashboard" do
    sign_out @provider
    patient = users(:patient_user)
    sign_in patient

    visit provider_analytics_path

    # Should be redirected with access denied message
    assert_text "Access denied"
    assert_current_path root_path
  end

  test "unauthenticated user cannot access analytics dashboard" do
    sign_out @provider

    visit provider_analytics_path

    # Should be redirected to sign in
    assert_current_path new_user_session_path
  end
end
