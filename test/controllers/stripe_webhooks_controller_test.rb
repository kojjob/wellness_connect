require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @appointment = appointments(:appointment_one)
    @payment = payments(:payment_one)

    # Setup payment with pending status
    @payment.update!(
      appointment: @appointment,
      payer: @patient,
      status: :pending,
      stripe_payment_intent_id: "pi_test_webhook_123"
    )

    # Setup appointment as payment_pending
    @appointment.update!(status: :payment_pending)
  end

  # ===== PAYMENT INTENT SUCCEEDED TESTS =====

  test "should handle payment_intent.succeeded webhook and update payment status" do
    webhook_payload = {
      type: "payment_intent.succeeded",
      data: {
        object: {
          id: @payment.stripe_payment_intent_id,
          amount: 15000,
          currency: "usd",
          status: "succeeded"
        }
      }
    }

    assert_difference -> { Notification.count }, 2 do # patient + provider notifications
      post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok
    assert_equal "success", JSON.parse(response.body)["message"]

    # Verify payment status updated
    @payment.reload
    assert @payment.succeeded?, "Payment should be marked as succeeded"
    assert_not_nil @payment.paid_at, "Payment paid_at timestamp should be set"

    # Verify appointment status updated
    @appointment.reload
    assert @appointment.scheduled?, "Appointment should be marked as scheduled"
  end

  test "should not update appointment if already in non-payment_pending status" do
    @appointment.update!(status: :completed)

    webhook_payload = {
      type: "payment_intent.succeeded",
      data: {
        object: {
          id: @payment.stripe_payment_intent_id,
          status: "succeeded"
        }
      }
    }

    post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :ok

    @appointment.reload
    assert @appointment.completed?, "Appointment status should remain completed"
  end

  test "should log warning if payment not found for succeeded payment intent" do
    webhook_payload = {
      type: "payment_intent.succeeded",
      data: {
        object: {
          id: "pi_nonexistent_123",
          status: "succeeded"
        }
      }
    }

    assert_no_difference "Payment.count" do
      post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok
  end

  # ===== PAYMENT INTENT FAILED TESTS =====

  test "should handle payment_intent.payment_failed webhook" do
    # Create availability slot that should be released
    availability = Availability.create!(
      provider_profile: @appointment.service.provider_profile,
      start_time: @appointment.start_time,
      end_time: @appointment.end_time,
      is_booked: true
    )

    webhook_payload = {
      type: "payment_intent.payment_failed",
      data: {
        object: {
          id: @payment.stripe_payment_intent_id,
          status: "failed"
        }
      }
    }

    assert_difference -> { Notification.count }, 1 do # patient notification
      post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok

    # Verify payment status updated
    @payment.reload
    assert @payment.failed?, "Payment should be marked as failed"

    # Verify appointment cancelled
    @appointment.reload
    assert @appointment.cancelled_by_patient?, "Appointment should be cancelled"
    assert_equal "Payment failed", @appointment.cancellation_reason

    # Verify availability slot released
    availability.reload
    assert_not availability.is_booked?, "Availability slot should be released"
  end

  test "should not cancel appointment if already in non-payment_pending status for failed payment" do
    @appointment.update!(status: :scheduled)

    webhook_payload = {
      type: "payment_intent.payment_failed",
      data: {
        object: {
          id: @payment.stripe_payment_intent_id,
          status: "failed"
        }
      }
    }

    post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :ok

    @appointment.reload
    assert @appointment.scheduled?, "Appointment status should remain scheduled"
  end

  # ===== CHARGE REFUNDED TESTS (NEW - TDD RED PHASE) =====

  test "should handle charge.refunded webhook and mark payment as refunded" do
    # Setup completed appointment and successful payment
    @payment.update!(status: :succeeded, paid_at: 1.day.ago)
    @appointment.update!(status: :completed)

    webhook_payload = {
      type: "charge.refunded",
      data: {
        object: {
          payment_intent: @payment.stripe_payment_intent_id,
          amount_refunded: 15000,
          refunded: true,
          refunds: {
            data: [
              {
                id: "re_test_refund_123",
                amount: 15000,
                status: "succeeded",
                created: Time.current.to_i
              }
            ]
          }
        }
      }
    }

    assert_difference -> { Notification.count }, 1 do # refund confirmation notification
      post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok

    # Verify payment status updated
    @payment.reload
    assert @payment.refunded?, "Payment should be marked as refunded"
    assert_not_nil @payment.refunded_at, "Payment refunded_at timestamp should be set"
  end

  test "should handle partial refund in charge.refunded webhook" do
    @payment.update!(status: :succeeded, paid_at: 1.day.ago, amount: 150.00)

    webhook_payload = {
      type: "charge.refunded",
      data: {
        object: {
          payment_intent: @payment.stripe_payment_intent_id,
          amount_refunded: 7500, # 50% refund
          refunded: true,
          refunds: {
            data: [
              {
                id: "re_test_partial_123",
                amount: 7500,
                status: "succeeded"
              }
            ]
          }
        }
      }
    }

    post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :ok

    @payment.reload
    assert @payment.refunded?, "Payment should be marked as refunded even for partial refunds"
    assert_not_nil @payment.refunded_at
  end

  test "should log warning if payment not found for charge.refunded webhook" do
    webhook_payload = {
      type: "charge.refunded",
      data: {
        object: {
          payment_intent: "pi_nonexistent_refund_123",
          amount_refunded: 15000,
          refunded: true
        }
      }
    }

    assert_no_difference "Payment.count" do
      post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok
  end

  test "should not process refund webhook if payment already refunded" do
    @payment.update!(status: :refunded, refunded_at: 2.days.ago)

    webhook_payload = {
      type: "charge.refunded",
      data: {
        object: {
          payment_intent: @payment.stripe_payment_intent_id,
          amount_refunded: 15000,
          refunded: true
        }
      }
    }

    # Should not create duplicate notification
    assert_no_difference "Notification.count" do
      post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok
  end

  # ===== ERROR HANDLING TESTS =====

  test "should handle unrecognized event types gracefully" do
    webhook_payload = {
      type: "unknown.event.type",
      data: {
        object: {}
      }
    }

    post stripe_webhooks_url, params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :ok
    assert_equal "success", JSON.parse(response.body)["message"]
  end
end
