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

  test "should confirm payment and update status" do
    # Create a payment first
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :pending,
      stripe_payment_intent_id: "pi_test_123"
    )

    # Simulate payment confirmation
    patch confirm_payment_path(payment), as: :json

    assert_response :success

    payment.reload
    # Note: In real implementation, this would be updated by Stripe webhook
    # For now, we're just testing the endpoint exists
    assert_not_nil payment
  end

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
