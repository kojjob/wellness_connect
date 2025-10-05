require "test_helper"
require "ostruct"

class RefundServiceTest < ActiveSupport::TestCase
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @service = services(:service_one)
    @appointment = appointments(:appointment_one)
    @payment = payments(:payment_one)

    # Ensure payment is linked to appointment
    @payment.update!(
      appointment: @appointment,
      payer: @patient,
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_123"
    )
  end

  # ===== CANCELLATION POLICY TESTS =====

  test "should process full refund when cancelled more than 24 hours before appointment" do
    # Set appointment start time to 48 hours from now
    new_start = 48.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    # Mock Stripe refund API
    Stripe::Refund.expects(:create).with(
      payment_intent: @payment.stripe_payment_intent_id,
      amount: (@payment.amount * 100).to_i # Convert to cents
    ).returns(OpenStruct.new(id: "re_test_123", status: "succeeded"))

    result = RefundService.process_refund(@payment, "Patient cancelled")

    assert result[:success], "Refund should succeed"
    assert_equal "full", result[:refund_type]
    assert_equal @payment.amount, result[:refund_amount]

    # Verify payment status updated
    @payment.reload
    assert @payment.refunded?
    assert_not_nil @payment.refunded_at
  end

  test "should process no refund when cancelled less than 24 hours before appointment" do
    # Set appointment start time to 12 hours from now
    new_start = 12.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    # Stripe API should NOT be called
    Stripe::Refund.expects(:create).never

    result = RefundService.process_refund(@payment, "Patient cancelled")

    assert result[:success], "Service should complete successfully"
    assert_equal "none", result[:refund_type]
    assert_equal 0, result[:refund_amount]

    # Payment should remain succeeded (not refunded)
    @payment.reload
    assert @payment.succeeded?
  end

  test "should process partial refund when cancelled between 24-48 hours before appointment" do
    # Set appointment start time to 36 hours from now
    new_start = 36.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    expected_refund = @payment.amount * 0.5 # 50% refund

    # Mock Stripe partial refund
    Stripe::Refund.expects(:create).with(
      payment_intent: @payment.stripe_payment_intent_id,
      amount: (expected_refund * 100).to_i
    ).returns(OpenStruct.new(id: "re_test_partial", status: "succeeded"))

    result = RefundService.process_refund(@payment, "Patient cancelled")

    assert result[:success]
    assert_equal "partial", result[:refund_type]
    assert_equal expected_refund, result[:refund_amount]
  end

  # ===== ERROR HANDLING TESTS =====

  test "should handle Stripe API failure gracefully" do
    new_start = 48.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    # Mock Stripe API failure
    Stripe::Refund.expects(:create).raises(Stripe::InvalidRequestError.new("Payment already refunded", nil))

    result = RefundService.process_refund(@payment, "Patient cancelled")

    assert_not result[:success]
    assert_includes result[:error], "Payment already refunded"

    # Payment status should NOT change
    @payment.reload
    assert @payment.succeeded?
  end

  test "should return error when payment already refunded" do
    @payment.update!(status: :refunded, refunded_at: 1.day.ago)

    result = RefundService.process_refund(@payment, "Duplicate request")

    assert_not result[:success]
    assert_includes result[:error], "already refunded"
  end

  test "should return error when payment is pending" do
    @payment.update!(status: :pending)

    result = RefundService.process_refund(@payment, "Cancel pending payment")

    assert_not result[:success]
    assert_includes result[:error].downcase, "cannot refund pending"
  end

  test "should return error when payment has no appointment" do
    @payment.update!(appointment: nil)

    result = RefundService.process_refund(@payment, "No appointment")

    assert_not result[:success]
    assert_includes result[:error], "no associated appointment"
  end

  # ===== REFUND POLICY CALCULATION TESTS =====

  test "should calculate full refund policy correctly" do
    new_start = 72.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    policy = RefundService.calculate_refund_policy(@payment)

    assert_equal "full", policy[:type]
    assert_equal 100, policy[:percentage]
    assert_equal @payment.amount, policy[:amount]
  end

  test "should calculate partial refund policy correctly" do
    new_start = 36.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    policy = RefundService.calculate_refund_policy(@payment)

    assert_equal "partial", policy[:type]
    assert_equal 50, policy[:percentage]
    assert_equal @payment.amount * 0.5, policy[:amount]
  end

  test "should calculate no refund policy correctly" do
    new_start = 6.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    policy = RefundService.calculate_refund_policy(@payment)

    assert_equal "none", policy[:type]
    assert_equal 0, policy[:percentage]
    assert_equal 0, policy[:amount]
  end

  # ===== NOTIFICATION TESTS =====

  test "should send refund notification to patient on successful full refund" do
    new_start = 48.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    Stripe::Refund.expects(:create).returns(OpenStruct.new(id: "re_test", status: "succeeded"))

    # Expect notification service to be called
    NotificationService.expects(:notify_refund_processed).with(@payment, "full", @payment.amount)

    RefundService.process_refund(@payment, "Patient cancelled")
  end

  test "should send notification for partial refund" do
    new_start = 36.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)
    expected_refund = @payment.amount * 0.5

    Stripe::Refund.expects(:create).returns(OpenStruct.new(id: "re_test", status: "succeeded"))
    NotificationService.expects(:notify_refund_processed).with(@payment, "partial", expected_refund)

    RefundService.process_refund(@payment, "Patient cancelled")
  end

  test "should send notification for no refund policy" do
    new_start = 6.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    NotificationService.expects(:notify_no_refund_policy).with(@payment)

    RefundService.process_refund(@payment, "Late cancellation")
  end

  # ===== EDGE CASES =====

  test "should handle appointment exactly at 24 hour boundary" do
    new_start = 24.hours.from_now
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    policy = RefundService.calculate_refund_policy(@payment)

    # At exactly 24 hours, should be partial refund
    assert_equal "partial", policy[:type]
  end

  test "should handle past appointment gracefully" do
    new_start = 2.hours.ago
    @appointment.update!(start_time: new_start, end_time: new_start + 1.hour)

    policy = RefundService.calculate_refund_policy(@payment)

    # Past appointments should not be refundable
    assert_equal "none", policy[:type]
  end
end
