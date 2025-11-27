class StripeWebhooksController < ApplicationController
  # Skip CSRF verification for Stripe webhooks
  skip_before_action :verify_authenticity_token
  # Skip authentication for Stripe webhooks (external service)
  skip_before_action :authenticate_user!

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      # SECURITY: Always verify webhook signature in non-test environments
      # Raise error if webhook secret is not configured in production/development
      if endpoint_secret.nil? && !Rails.env.test?
        Rails.logger.error "Stripe webhook secret not configured - rejecting webhook"
        render json: { error: "Webhook secret not configured" }, status: :internal_server_error
        return
      end

      # Verify webhook signature (skip only in test environment with explicit nil secret)
      event = if Rails.env.test? && endpoint_secret.nil?
        # In test environment without webhook secret, parse the payload directly
        # This is ONLY for testing - production MUST have signature verification
        JSON.parse(payload, symbolize_names: true)
      else
        Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )
      end

      # Handle the event
      case event[:type]
      when "payment_intent.succeeded"
        handle_payment_succeeded(event[:data][:object])
      when "payment_intent.payment_failed"
        handle_payment_failed(event[:data][:object])
      when "charge.refunded"
        handle_charge_refunded(event[:data][:object])
      else
        Rails.logger.info "Unhandled Stripe event type: #{event[:type]}"
      end

      render json: { message: "success" }, status: :ok
    rescue JSON::ParserError => e
      Rails.logger.error "Stripe webhook JSON parse error: #{e.message}"
      render json: { error: "Invalid payload" }, status: :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Stripe webhook signature verification failed: #{e.message}"
      render json: { error: "Invalid signature" }, status: :bad_request
    end
  end

  private

  def handle_payment_succeeded(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent[:id])

    if payment
      ActiveRecord::Base.transaction do
        # Update payment status
        payment.update!(
          status: :succeeded,
          paid_at: Time.current
        )

        # Update appointment status from payment_pending to scheduled
        if payment.appointment
          appointment = payment.appointment

          if appointment.payment_pending?
            appointment.update!(status: :scheduled)

            # Send confirmation notifications to both patient and provider
            NotificationService.notify_appointment_booked(appointment)

            Rails.logger.info "Appointment #{appointment.id} confirmed: payment #{payment.id} succeeded"
          else
            Rails.logger.info "Payment #{payment.id} succeeded but appointment #{appointment.id} already in #{appointment.status} status"
          end
        end
      end

      Rails.logger.info "Payment #{payment.id} succeeded for appointment #{payment.appointment_id}"
    else
      Rails.logger.warn "Payment not found for payment intent: #{payment_intent[:id]}"
    end
  end

  def handle_payment_failed(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent[:id])

    if payment
      ActiveRecord::Base.transaction do
        # Update payment status
        payment.update!(status: :failed)

        # Release availability slot and cancel appointment if payment fails
        if payment.appointment
          appointment = payment.appointment

          if appointment.payment_pending?
            # Find and release the availability slot
            availability = Availability.find_by(
              provider_profile: appointment.service.provider_profile,
              start_time: appointment.start_time,
              end_time: appointment.end_time,
              is_booked: true
            )

            if availability
              availability.update!(is_booked: false)
              Rails.logger.info "Released availability slot #{availability.id} for failed payment"
            end

            # Cancel the appointment
            appointment.update!(
              status: :cancelled_by_patient,
              cancellation_reason: "Payment failed"
            )

            # Notify patient about failed payment
            Notification.create!(
              user: appointment.patient,
              title: "Payment Failed",
              message: "Your payment for the appointment on #{appointment.start_time.strftime('%B %d at %I:%M %p')} failed. The appointment has been cancelled. Please try booking again.",
              notification_type: "payment_failed",
              action_url: "/appointments/new?availability_id=#{availability&.id}"
            )

            Rails.logger.info "Appointment #{appointment.id} cancelled: payment #{payment.id} failed"
          else
            Rails.logger.info "Payment #{payment.id} failed but appointment #{appointment.id} already in #{appointment.status} status"
          end
        end
      end

      Rails.logger.info "Payment #{payment.id} failed for appointment #{payment.appointment_id}"
    else
      Rails.logger.warn "Payment not found for payment intent: #{payment_intent[:id]}"
    end
  end

  def handle_charge_refunded(charge)
    # Extract payment_intent from charge object
    payment_intent_id = charge[:payment_intent]
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent_id)

    if payment
      # Skip if payment already refunded (prevent duplicate notifications)
      if payment.refunded?
        Rails.logger.info "Payment #{payment.id} already refunded, skipping duplicate webhook"
        return
      end

      ActiveRecord::Base.transaction do
        # Update payment status to refunded
        payment.update!(
          status: :refunded,
          refunded_at: Time.current
        )

        # Determine refund type based on amount refunded
        amount_refunded_dollars = charge[:amount_refunded] / 100.0
        refund_type = if amount_refunded_dollars >= payment.amount
          "full"
        else
          "partial"
        end

        # Send refund confirmation notification
        NotificationService.notify_refund_processed(payment, refund_type, amount_refunded_dollars)

        Rails.logger.info "Payment #{payment.id} marked as refunded: #{refund_type} refund of $#{amount_refunded_dollars}"
      end
    else
      Rails.logger.warn "Payment not found for payment intent: #{payment_intent_id}"
    end
  end
end
