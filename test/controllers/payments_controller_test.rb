require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @service = services(:service_one)

    # Create an availability
    @availability = Availability.create!(
      provider_profile: @provider.provider_profile,
      start_time: 2.days.from_now.change(hour: 10),
      end_time: 2.days.from_now.change(hour: 11),
      is_booked: false
    )

    # Create an appointment
    @appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: @availability.start_time,
      end_time: @availability.end_time,
      status: :scheduled
    )

    sign_in @patient
  end

  test "should create payment intent for appointment" do
    assert_difference "Payment.count", 1 do
      post payments_path, params: {
        payment: {
          appointment_id: @appointment.id,
          amount: @service.price
        }
      }, as: :json
    end

    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["client_secret"].present?, "Client secret should be present"
    assert json_response["payment_intent_id"].present?, "Payment intent ID should be present"

    # Verify payment was created with correct attributes
    payment = Payment.last
    assert_equal @patient.id, payment.payer_id
    assert_equal @appointment.id, payment.appointment_id
    assert_equal @service.price, payment.amount
    assert_equal "USD", payment.currency
    assert_equal "pending", payment.status
    assert payment.stripe_payment_intent_id.present?
  end

  test "should not create payment intent without authentication" do
    sign_out @patient

    assert_no_difference "Payment.count" do
      post payments_path, params: {
        payment: {
          appointment_id: @appointment.id,
          amount: @service.price
        }
      }, as: :json
    end

    assert_response :unauthorized
  end

  test "should not create payment intent for appointment belonging to another user" do
    other_patient = users(:patient_user_two)
    other_appointment = Appointment.create!(
      patient: other_patient,
      provider: @provider,
      service: @service,
      start_time: 3.days.from_now.change(hour: 10),
      end_time: 3.days.from_now.change(hour: 11),
      status: :scheduled
    )

    assert_no_difference "Payment.count" do
      post payments_path, params: {
        payment: {
          appointment_id: other_appointment.id,
          amount: @service.price
        }
      }, as: :json
    end

    assert_response :forbidden
  end

  # Payment Confirmation Tests

  test "should confirm pending payment successfully" do
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_confirm_success"
    )

    assert_equal "pending", payment.status
    assert_nil payment.paid_at

    patch confirm_payment_path(payment), params: {
      payment_intent_id: payment.stripe_payment_intent_id
    }, as: :json

    assert_response :success
    payment.reload
    assert_equal "succeeded", payment.status
    assert_not_nil payment.paid_at
  end

  test "should update appointment status to scheduled when payment confirmed" do
    @appointment.update!(status: :payment_pending)

    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_appointment_update"
    )

    assert_equal "payment_pending", @appointment.status

    patch confirm_payment_path(payment), params: {
      payment_intent_id: payment.stripe_payment_intent_id
    }, as: :json

    assert_response :success
    @appointment.reload
    assert_equal "scheduled", @appointment.status
  end

  test "should return success response with payment details on confirmation" do
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_response_details"
    )

    patch confirm_payment_path(payment), params: {
      payment_intent_id: payment.stripe_payment_intent_id
    }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "succeeded", json_response["status"]
    assert_equal payment.id, json_response["payment"]["id"]
    assert_equal "succeeded", json_response["payment"]["status"]
    assert_not_nil json_response["payment"]["paid_at"]
  end

  test "should not allow confirming another user's payment" do
    other_patient = users(:patient_user_two)
    payment = Payment.create!(
      payer: other_patient,
      appointment: Appointment.create!(
        patient: other_patient,
        provider: @provider,
        service: @service,
        start_time: 4.days.from_now.change(hour: 10),
        end_time: 4.days.from_now.change(hour: 11),
        status: :payment_pending
      ),
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_other_user"
    )

    patch confirm_payment_path(payment), params: {
      payment_intent_id: payment.stripe_payment_intent_id
    }, as: :json

    assert_response :forbidden
  end

  test "should handle already confirmed payment idempotently" do
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_idempotent"
    )

    # First confirmation
    patch confirm_payment_path(payment), params: {
      payment_intent_id: payment.stripe_payment_intent_id
    }, as: :json
    assert_response :success

    original_paid_at = payment.reload.paid_at

    # Wait a moment
    sleep 0.1

    # Second confirmation - should still succeed and not change paid_at
    patch confirm_payment_path(payment), params: {
      payment_intent_id: payment.stripe_payment_intent_id
    }, as: :json
    assert_response :success

    payment.reload
    assert_equal "succeeded", payment.status
    assert_equal original_paid_at.to_i, payment.paid_at.to_i
  end

  test "should return 404 for non-existent payment" do
    patch confirm_payment_path(id: 99999), params: {
      payment_intent_id: "pi_test_nonexistent"
    }, as: :json

    assert_response :not_found
  end

  test "should return error if payment_intent_id doesn't match" do
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_mismatch"
    )

    patch confirm_payment_path(payment), params: {
      payment_intent_id: "pi_wrong_intent_id"
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert_match /payment intent/i, json_response["message"]
  end

  test "should return error if payment_intent_id is missing" do
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_missing_param"
    )

    patch confirm_payment_path(payment), params: {}, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert_match /payment intent/i, json_response["message"]
  end

  test "should handle failed payment status" do
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :failed,
      stripe_payment_intent_id: "pi_test_already_failed"
    )

    patch confirm_payment_path(payment), params: {
      payment_intent_id: payment.stripe_payment_intent_id
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert_match /cannot confirm.*failed/i, json_response["message"]
  end

  # Note: Transaction rollback test would require more complex setup with
  # test doubles or database constraints. Skipping for now as the transaction
  # safety is tested through integration tests and webhook tests.

  test "should handle Stripe webhook events" do
    # Simulate a Stripe webhook for payment succeeded
    event_payload = {
      type: "payment_intent.succeeded",
      data: {
        object: {
          id: "pi_test_123",
          amount: (@service.price * 100).to_i, # Stripe uses cents
          currency: "usd",
          status: "succeeded"
        }
      }
    }

    # Create a pending payment
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_123"
    )

    # Note: In production, we would verify Stripe signature
    # For testing, we'll send the webhook without signature verification
    post stripe_webhooks_path,
      params: event_payload.to_json,
      headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :success

    # Verify payment status was updated
    payment.reload
    assert_equal "succeeded", payment.status
    assert_not_nil payment.paid_at
  end
end
