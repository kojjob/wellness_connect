class StripeWebhooksController < ApplicationController
  # Skip CSRF verification for Stripe webhooks
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      # Verify webhook signature (skip in test environment)
      event = if Rails.env.test? && endpoint_secret.nil?
        # In test environment without webhook secret, parse the payload directly
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
end
