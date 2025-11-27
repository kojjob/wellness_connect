require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  def setup
    @patient = users(:patient_user)
    @appointment = appointments(:appointment_one)
    @payment = payments(:payment_one)
  end

  # Validation Tests
  test "should be valid with all required attributes" do
    payment = Payment.new(
      payer: @patient,
      appointment: @appointment,
      amount: 100.00,
      currency: "USD",
      status: :pending
    )
    assert payment.valid?, "Payment should be valid: #{payment.errors.full_messages.join(', ')}"
  end

  test "should require amount" do
    payment = Payment.new(payer: @patient, currency: "USD")
    assert_not payment.valid?
    assert_includes payment.errors[:amount], "can't be blank"
  end

  test "should require positive amount" do
    payment = Payment.new(payer: @patient, currency: "USD", amount: -10)
    assert_not payment.valid?
    assert_includes payment.errors[:amount], "must be greater than 0"
  end

  test "should not allow zero amount" do
    payment = Payment.new(payer: @patient, currency: "USD", amount: 0)
    assert_not payment.valid?
    assert_includes payment.errors[:amount], "must be greater than 0"
  end

  test "should require currency" do
    payment = Payment.new(payer: @patient, amount: 100)
    assert_not payment.valid?
    assert_includes payment.errors[:currency], "can't be blank"
  end

  test "should require valid 3-letter currency code" do
    payment = Payment.new(payer: @patient, amount: 100, currency: "US")
    assert_not payment.valid?
    assert_includes payment.errors[:currency], "must be a 3-letter currency code"
  end

  test "should accept valid 3-letter currency code" do
    payment = Payment.new(payer: @patient, amount: 100, currency: "USD", status: :pending)
    assert payment.valid?, "Payment with USD should be valid"

    payment.currency = "EUR"
    assert payment.valid?, "Payment with EUR should be valid"

    payment.currency = "GBP"
    assert payment.valid?, "Payment with GBP should be valid"
  end

  test "currency must be uppercase" do
    payment = Payment.new(payer: @patient, amount: 100, currency: "usd")
    assert_not payment.valid?
    assert_includes payment.errors[:currency], "must be a 3-letter currency code"
  end

  test "should require payer" do
    payment = Payment.new(amount: 100, currency: "USD")
    assert_not payment.valid?
    assert_includes payment.errors[:payer], "must exist"
  end

  test "should require stripe_payment_intent_id when succeeded" do
    payment = Payment.new(
      payer: @patient,
      amount: 100,
      currency: "USD",
      status: :succeeded,
      stripe_payment_intent_id: nil
    )
    assert_not payment.valid?
    assert_includes payment.errors[:stripe_payment_intent_id], "can't be blank"
  end

  test "should require stripe_payment_intent_id when refunded" do
    payment = Payment.new(
      payer: @patient,
      amount: 100,
      currency: "USD",
      status: :refunded,
      stripe_payment_intent_id: nil
    )
    assert_not payment.valid?
    assert_includes payment.errors[:stripe_payment_intent_id], "can't be blank"
  end

  test "should not require stripe_payment_intent_id when pending" do
    payment = Payment.new(
      payer: @patient,
      amount: 100,
      currency: "USD",
      status: :pending
    )
    assert payment.valid?
  end

  test "stripe_payment_intent_id should be unique" do
    payment = Payment.new(
      payer: @patient,
      amount: 100,
      currency: "USD",
      status: :succeeded,
      stripe_payment_intent_id: @payment.stripe_payment_intent_id
    )
    assert_not payment.valid?
    assert_includes payment.errors[:stripe_payment_intent_id], "has already been taken"
  end

  # Status Enum Tests
  test "should have correct status values" do
    assert_equal 0, Payment.statuses[:pending]
    assert_equal 1, Payment.statuses[:succeeded]
    assert_equal 2, Payment.statuses[:failed]
    assert_equal 3, Payment.statuses[:refunded]
  end

  test "default status should be pending" do
    payment = Payment.new
    assert_equal "pending", payment.status
  end

  # Scope Tests
  test "successful scope returns succeeded payments" do
    assert_includes Payment.successful, @payment
  end

  test "pending_payments scope returns pending payments" do
    pending_payment = Payment.create!(
      payer: @patient,
      amount: 50,
      currency: "USD",
      status: :pending
    )
    assert_includes Payment.pending_payments, pending_payment
    assert_not_includes Payment.pending_payments, @payment
  end

  test "recent scope orders by created_at desc" do
    old_payment = Payment.create!(
      payer: @patient,
      amount: 50,
      currency: "USD",
      status: :pending,
      created_at: 1.week.ago
    )
    new_payment = Payment.create!(
      payer: @patient,
      amount: 75,
      currency: "USD",
      status: :pending,
      created_at: 1.day.ago
    )

    recent = Payment.recent
    assert recent.index(new_payment) < recent.index(old_payment)
  end

  # Instance Method Tests
  test "refundable? returns true for succeeded payment with stripe_id" do
    assert @payment.refundable?
  end

  test "refundable? returns false for pending payment" do
    @payment.status = :pending
    assert_not @payment.refundable?
  end

  test "refundable? returns false for failed payment" do
    @payment.status = :failed
    assert_not @payment.refundable?
  end

  test "refundable? returns false if no stripe_payment_intent_id" do
    @payment.stripe_payment_intent_id = nil
    @payment.status = :succeeded
    assert_not @payment.refundable?
  end

  test "formatted_amount returns dollar formatted string" do
    @payment.amount = 150.50
    assert_equal "$150.50", @payment.formatted_amount
  end

  test "formatted_amount handles whole numbers" do
    @payment.amount = 100
    assert_equal "$100.00", @payment.formatted_amount
  end

  test "paid? returns true for succeeded payments" do
    @payment.status = :succeeded
    assert @payment.paid?
  end

  test "paid? returns false for pending payments" do
    @payment.status = :pending
    assert_not @payment.paid?
  end

  # Association Tests
  test "should belong to payer" do
    assert_respond_to @payment, :payer
    assert_equal @patient, @payment.payer
  end

  test "should optionally belong to appointment" do
    assert_respond_to @payment, :appointment
    # Create payment without appointment
    payment = Payment.new(
      payer: @patient,
      amount: 100,
      currency: "USD",
      status: :pending
    )
    assert payment.valid?
  end
end
