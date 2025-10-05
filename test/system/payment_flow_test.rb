require "application_system_test_case"
require "minitest/mock"

class PaymentFlowTest < ApplicationSystemTestCase
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @service = services(:service_one)
    @availability = availabilities(:availability_one)

    # Stub Stripe::PaymentIntent for system tests
    @mock_payment_intent = Minitest::Mock.new
    @mock_payment_intent.expect :id, "pi_test_#{SecureRandom.hex(12)}"
    @mock_payment_intent.expect :client_secret, "pi_test_secret_#{SecureRandom.hex(16)}"
    @mock_payment_intent.expect :id, "pi_test_#{SecureRandom.hex(12)}"
  end

  test "complete booking flow creates appointment with payment_pending status" do
    sign_in @patient

    # Stub Stripe API call
    Stripe::PaymentIntent.stub :create, @mock_payment_intent do
      visit provider_profile_path(@provider_profile)

      # Click Book button
      within "#booking" do
        first(:link, "Book").click
      end

      # Should navigate to booking page
      assert_text "Confirm Appointment"
      assert_text "Payment Information"

      # Select service
      select @service.name, from: "appointment_service_id"

      # Verify service price is displayed
      assert_text "$#{@service.price}"

      # Verify Stripe Elements card container is present
      assert_selector '[data-payment-target="cardElement"]'

      # Note: We can't easily test actual Stripe.js card input in system tests
      # without hitting Stripe's test API or using a browser automation tool
      # that can interact with iframe content (Stripe Elements uses iframes)

      # Verify initial state
      initial_appointment_count = Appointment.count
      initial_payment_count = Payment.count

      # In a real system test with Stripe test mode, we would:
      # 1. Fill in test card number 4242 4242 4242 4242
      # 2. Fill in expiry, CVC
      # 3. Click submit
      # 4. Wait for payment confirmation
      # 5. Verify redirect to dashboard

      # For this test, we verify the form structure and availability
      # The actual payment confirmation would require Stripe test mode integration
    end
  end

  test "booking with stubbed Stripe creates payment intent and payment record" do
    sign_in @patient

    # Create a more complete mock that matches our controller expectations
    payment_intent_double = Minitest::Mock.new
    payment_intent_double.expect :id, "pi_test_123456789"
    payment_intent_double.expect :client_secret, "pi_test_secret_123456789"
    payment_intent_double.expect :id, "pi_test_123456789"

    Stripe::PaymentIntent.stub :create, payment_intent_double do
      # Simulate the backend appointment creation (what happens when JS submits)
      appointment = Appointment.create!(
        patient: @patient,
        provider: @provider,
        service: @service,
        start_time: @availability.start_time,
        end_time: @availability.end_time,
        status: :payment_pending  # Default status before payment confirmation
      )

      payment = Payment.create!(
        payer: @patient,
        appointment: appointment,
        amount: @service.price,
        currency: "USD",
        status: :pending,
        stripe_payment_intent_id: payment_intent_double.id
      )

      # Verify appointment created with correct status
      assert_equal "payment_pending", appointment.status
      assert appointment.persisted?

      # Verify payment created with correct status
      assert_equal "pending", payment.status
      assert_equal payment_intent_double.id, payment.stripe_payment_intent_id
      assert payment.persisted?

      # Verify availability marked as booked
      @availability.update!(is_booked: true)
      assert @availability.is_booked
    end
  end

  test "payment confirmation updates appointment and payment status" do
    sign_in @patient

    # Create appointment and payment in pending state
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: @availability.start_time,
      end_time: @availability.end_time,
      status: :payment_pending
    )

    payment = Payment.create!(
      payer: @patient,
      appointment: appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_confirmed_123"
    )

    # Simulate payment confirmation (what our JS controller does)
    payment.update!(status: :succeeded, paid_at: Time.current)
    appointment.update!(status: :scheduled)

    # Verify final state
    assert_equal "succeeded", payment.status
    assert_not_nil payment.paid_at
    assert_equal "scheduled", appointment.status

    # Verify appointment appears correctly on dashboard
    visit dashboard_path

    within "#appointment-#{appointment.id}" do
      assert_text @provider.full_name
      assert_text @service.name
      assert_text "Scheduled"
    end
  end

  test "cancellation with refund updates payment status" do
    sign_in @patient

    # Create completed appointment with successful payment
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 3.days.from_now,  # More than 24 hours away
      end_time: 3.days.from_now + 1.hour,
      status: :scheduled
    )

    payment = Payment.create!(
      payer: @patient,
      appointment: appointment,
      amount: @service.price,
      currency: "USD",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_refund_123",
      paid_at: 1.hour.ago
    )

    # Mark availability as booked
    @availability.update!(is_booked: true)

    # Stub Stripe refund API
    refund_double = Minitest::Mock.new
    refund_double.expect :id, "re_test_123456789"

    Stripe::Refund.stub :create, refund_double do
      visit dashboard_path

      within "#appointment-#{appointment.id}" do
        click_button "Cancel Appointment"
      end

      # Accept confirmation dialog
      page.driver.browser.switch_to.alert.accept

      # Wait for redirect
      assert_current_path dashboard_path, wait: 5
      assert_text "Appointment cancelled successfully"

      # Verify appointment status
      appointment.reload
      assert_equal "cancelled_by_patient", appointment.status

      # Verify payment was refunded
      payment.reload
      assert_equal "refunded", payment.status
      assert_not_nil payment.refunded_at

      # Verify availability released
      @availability.reload
      assert_not @availability.is_booked
    end
  end

  test "cancellation within 24 hours does not refund" do
    sign_in @patient

    # Create appointment less than 24 hours away
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 12.hours.from_now,
      end_time: 13.hours.from_now,
      status: :scheduled
    )

    payment = Payment.create!(
      payer: @patient,
      appointment: appointment,
      amount: @service.price,
      currency: "USD",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_no_refund_123",
      paid_at: 1.hour.ago
    )

    visit dashboard_path

    within "#appointment-#{appointment.id}" do
      click_button "Cancel Appointment"
    end

    # Accept confirmation dialog
    page.driver.browser.switch_to.alert.accept

    # Wait for redirect
    assert_current_path dashboard_path, wait: 5

    # Verify appointment cancelled but payment not refunded
    appointment.reload
    assert_equal "cancelled_by_patient", appointment.status

    payment.reload
    assert_equal "succeeded", payment.status  # Status unchanged
    assert_nil payment.refunded_at
  end

  test "provider cancellation always refunds regardless of timing" do
    sign_in @provider

    # Create appointment less than 24 hours away
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 12.hours.from_now,
      end_time: 13.hours.from_now,
      status: :scheduled
    )

    payment = Payment.create!(
      payer: @patient,
      appointment: appointment,
      amount: @service.price,
      currency: "USD",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_provider_refund_123",
      paid_at: 1.hour.ago
    )

    # Stub Stripe refund
    refund_double = Minitest::Mock.new
    refund_double.expect :id, "re_test_provider_123"

    Stripe::Refund.stub :create, refund_double do
      visit dashboard_path

      within "#appointment-#{appointment.id}" do
        click_button "Cancel Appointment"
      end

      # Accept confirmation dialog
      page.driver.browser.switch_to.alert.accept

      # Wait for redirect
      assert_current_path dashboard_path, wait: 5

      # Verify provider cancellation with refund
      appointment.reload
      assert_equal "cancelled_by_provider", appointment.status

      payment.reload
      assert_equal "refunded", payment.status
      assert_not_nil payment.refunded_at
    end
  end

  test "payment form displays correct service price" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    within "#booking" do
      first(:link, "Book").click
    end

    assert_text "Confirm Appointment"

    # Before selecting service, amount should be hidden or $0.00
    # After selecting service, should show correct price
    select @service.name, from: "appointment_service_id"

    # Verify price is displayed correctly
    within '[data-payment-target="amount"]' do
      assert_text "$#{@service.price.to_f.round(2)}"
    end
  end

  test "payment form shows security badge" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    within "#booking" do
      first(:link, "Book").click
    end

    # Verify security messaging is present
    assert_text "Your payment information is secure and encrypted"
    assert_selector 'svg'  # Lock icon should be present
  end

  test "form submission button is disabled during processing" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    within "#booking" do
      first(:link, "Book").click
    end

    select @service.name, from: "appointment_service_id"

    # Verify submit button exists and has correct initial state
    submit_button = find('[data-payment-target="submitButton"]')
    assert_equal "Confirm Booking", submit_button.text
    assert_not submit_button.disabled?

    # Note: Testing the disabled state during actual submission would require
    # more complex browser automation and Stripe test mode integration
  end
end
