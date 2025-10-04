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
      payment.update!(
        status: :succeeded,
        paid_at: Time.current
      )

      # TODO: Send confirmation email to patient
      # TODO: Send notification to provider

      Rails.logger.info "Payment #{payment.id} succeeded for appointment #{payment.appointment_id}"
    else
      Rails.logger.warn "Payment not found for payment intent: #{payment_intent[:id]}"
    end
  end

  def handle_payment_failed(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent[:id])

    if payment
      payment.update!(status: :failed)

      # TODO: Notify patient about failed payment
      # TODO: Release availability slot if payment fails

      Rails.logger.info "Payment #{payment.id} failed for appointment #{payment.appointment_id}"
    else
      Rails.logger.warn "Payment not found for payment intent: #{payment_intent[:id]}"
    end
  end
end
