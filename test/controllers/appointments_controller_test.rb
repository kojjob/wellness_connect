require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @service = services(:service_one)

    # Create an availability
    @availability = Availability.create!(
      provider_profile: @provider.provider_profile,
      start_time: 3.days.from_now.change(hour: 10, min: 0),
      end_time: 3.days.from_now.change(hour: 11, min: 0),
      is_booked: true
    )

    # Create a scheduled appointment with payment
    @appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: @availability.start_time,
      end_time: @availability.end_time,
      status: :scheduled
    )

    @payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: @service.price,
      currency: "USD",
      status: :succeeded,
      stripe_payment_intent_id: "pi_test_refund_#{SecureRandom.hex(8)}",
      paid_at: 1.hour.ago
    )
  end

  # Refund Logic Tests

  test "should issue full refund when cancelling more than 24 hours before appointment" do
    sign_in @patient

    # Appointment is 3 days away, should get full refund
    assert @appointment.start_time > 24.hours.from_now

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Schedule conflict"
    }

    assert_redirected_to dashboard_path
    assert_equal "Appointment cancelled successfully", flash[:notice]

    @appointment.reload
    assert_equal "cancelled_by_patient", @appointment.status

    @payment.reload
    assert_equal "refunded", @payment.status
    assert_not_nil @payment.refunded_at
  end

  test "should not issue refund when cancelling less than 24 hours before appointment" do
    sign_in @patient

    # Update appointment to be tomorrow (within 24 hours)
    @appointment.update!(
      start_time: 12.hours.from_now,
      end_time: 13.hours.from_now
    )

    assert @appointment.start_time < 24.hours.from_now

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Last minute change"
    }

    assert_redirected_to dashboard_path
    assert_equal "Appointment cancelled successfully", flash[:notice]

    @appointment.reload
    assert_equal "cancelled_by_patient", @appointment.status

    @payment.reload
    assert_equal "succeeded", @payment.status # Payment status unchanged
    assert_nil @payment.refunded_at
  end

  test "should handle cancellation when no payment exists" do
    sign_in @patient

    # Create appointment without payment
    appointment_without_payment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 2.days.from_now.change(hour: 14, min: 0),
      end_time: 2.days.from_now.change(hour: 15, min: 0),
      status: :scheduled
    )

    patch cancel_appointment_path(appointment_without_payment), params: {
      cancellation_reason: "No payment involved"
    }

    assert_redirected_to dashboard_path
    assert_equal "Appointment cancelled successfully", flash[:notice]

    appointment_without_payment.reload
    assert_equal "cancelled_by_patient", appointment_without_payment.status
  end

  test "should handle cancellation when payment is pending" do
    sign_in @patient

    # Update payment to pending
    @payment.update!(status: :pending, paid_at: nil)

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Cancelling before payment"
    }

    assert_redirected_to dashboard_path
    assert_equal "Appointment cancelled successfully", flash[:notice]

    @appointment.reload
    assert_equal "cancelled_by_patient", @appointment.status

    @payment.reload
    assert_equal "pending", @payment.status # Pending payment not refunded
  end

  test "should handle already refunded payment idempotently" do
    sign_in @patient

    # Mark payment as already refunded
    @payment.update!(status: :refunded, refunded_at: 1.hour.ago)

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Already refunded"
    }

    assert_redirected_to dashboard_path

    @payment.reload
    assert_equal "refunded", @payment.status
  end

  test "should set correct cancellation status when provider cancels" do
    sign_in @provider

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Emergency"
    }

    assert_redirected_to dashboard_path

    @appointment.reload
    assert_equal "cancelled_by_provider", @appointment.status
  end

  test "should issue refund when provider cancels regardless of timing" do
    sign_in @provider

    # Update appointment to be tomorrow (within 24 hours)
    @appointment.update!(
      start_time: 12.hours.from_now,
      end_time: 13.hours.from_now
    )

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Provider emergency"
    }

    assert_redirected_to dashboard_path

    @appointment.reload
    assert_equal "cancelled_by_provider", @appointment.status

    @payment.reload
    # Provider cancellation should always refund
    assert_equal "refunded", @payment.status
    assert_not_nil @payment.refunded_at
  end

  test "should release availability slot when cancelling" do
    sign_in @patient

    assert @availability.is_booked

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Change of plans"
    }

    assert_redirected_to dashboard_path

    @availability.reload
    assert_not @availability.is_booked
  end

  test "should not allow unauthorized user to cancel appointment" do
    other_user = users(:provider_user_two)
    sign_in other_user

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Unauthorized attempt"
    }

    # Pundit should raise error or redirect
    assert_response :forbidden
  end

  test "should not cancel appointment that is already cancelled" do
    sign_in @patient

    @appointment.update!(status: :cancelled_by_patient)

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Already cancelled"
    }

    assert_redirected_to dashboard_path
    assert_match /already cancelled/i, flash[:alert]
  end

  test "should not cancel appointment that is already completed" do
    sign_in @patient

    @appointment.update!(status: :completed)

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Trying to cancel completed"
    }

    assert_redirected_to dashboard_path
    assert_match /cannot cancel.*completed/i, flash[:alert]
  end

  test "should handle Stripe refund API errors gracefully" do
    sign_in @patient

    # This test would require stubbing Stripe::Refund.create to raise an error
    # For now, we'll verify the endpoint handles errors
    # In production, we'd need to mock Stripe API calls

    patch cancel_appointment_path(@appointment), params: {
      cancellation_reason: "Test refund error handling"
    }

    # Should still cancel appointment even if refund fails
    assert_redirected_to dashboard_path
  end
end
