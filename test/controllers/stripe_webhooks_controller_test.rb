require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @service = services(:service_one)

    @appointment = appointments(:scheduled_appointment)
    @payment = payments(:pending_payment)
  end

  test "should accept webhook in test environment" do
    # In test environment, controller parses JSON directly (no signature verification needed)
    event_data = {
      id: "evt_test_webhook",
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

    post stripe_webhooks_path,
      params: event_data.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
  end

  test "should handle payment_intent.succeeded event" do
    # Verify initial state
    assert_equal "pending", @payment.status
    assert_equal "payment_pending", @appointment.status

    # Create Stripe event
    event_data = {
      id: "evt_test_webhook_success",
      type: "payment_intent.succeeded",
      data: {
        object: {
          id: @payment.stripe_payment_intent_id,
          amount: (@payment.amount * 100).to_i,
          currency: "usd",
          status: "succeeded",
          metadata: {
            appointment_id: @appointment.id.to_s,
            patient_id: @patient.id.to_s,
            provider_id: @provider.id.to_s
          }
        }
      }
    }

    post stripe_webhooks_path,
      params: event_data.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success

    # Verify payment updated
    @payment.reload
    assert_equal "succeeded", @payment.status
    assert_not_nil @payment.paid_at

    # Verify appointment updated to scheduled
    @appointment.reload
    assert_equal "scheduled", @appointment.status
  end

  test "should handle payment_intent.payment_failed event" do
    # Verify initial state
    assert_equal "pending", @payment.status
    assert_equal "payment_pending", @appointment.status

    # Get the availability that was booked
    availability = availabilities(:monday_morning)
    assert availability.is_booked, "Availability should be booked initially"

    # Create Stripe event for failed payment
    event_data = {
      id: "evt_test_webhook_failed",
      type: "payment_intent.payment_failed",
      data: {
        object: {
          id: @payment.stripe_payment_intent_id,
          amount: (@payment.amount * 100).to_i,
          currency: "usd",
          status: "requires_payment_method",
          last_payment_error: {
            message: "Your card was declined."
          },
          metadata: {
            appointment_id: @appointment.id.to_s,
            patient_id: @patient.id.to_s,
            provider_id: @provider.id.to_s
          }
        }
      }
    }

    post stripe_webhooks_path,
      params: event_data.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success

    # Verify payment updated to failed
    @payment.reload
    assert_equal "failed", @payment.status

    # Verify appointment cancelled
    @appointment.reload
    assert_equal "cancelled_by_system", @appointment.status

    # Verify availability released
    availability.reload
    assert_not availability.is_booked, "Availability should be released when payment fails"
  end

  test "should handle unknown event types gracefully" do
    event_data = {
      id: "evt_test_unknown",
      type: "unknown.event.type",
      data: { object: { id: "obj_unknown" } }
    }

    post stripe_webhooks_path,
      params: event_data.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
  end

  test "should handle duplicate webhook events idempotently" do
    # First webhook
    event_data = {
      id: "evt_test_duplicate",
      type: "payment_intent.succeeded",
      data: {
        object: {
          id: @payment.stripe_payment_intent_id,
          amount: (@payment.amount * 100).to_i,
          currency: "usd",
          status: "succeeded"
        }
      }
    }

    # Post first time
    post stripe_webhooks_path,
      params: event_data.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
    @payment.reload
    assert_equal "succeeded", @payment.status

    # Post duplicate - should handle gracefully
    post stripe_webhooks_path,
      params: event_data.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
    @payment.reload
    assert_equal "succeeded", @payment.status # Still succeeded, not changed
  end
end
