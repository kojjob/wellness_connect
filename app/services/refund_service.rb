class RefundService
  # Cancellation policy thresholds (in hours before appointment)
  FULL_REFUND_THRESHOLD = 48.hours
  PARTIAL_REFUND_THRESHOLD = 24.hours
  PARTIAL_REFUND_PERCENTAGE = 0.5 # 50% refund

  # Process refund for a payment based on cancellation policy
  #
  # @param payment [Payment] The payment to refund
  # @param reason [String] Reason for the refund
  # @return [Hash] Result hash with :success, :refund_type, :refund_amount, :error keys
  def self.process_refund(payment, reason)
    # Validate payment eligibility
    validation_result = validate_payment_for_refund(payment)
    return validation_result unless validation_result[:success]

    # Calculate refund policy
    policy = calculate_refund_policy(payment)

    # Handle no refund case
    if policy[:type] == "none"
      NotificationService.notify_no_refund_policy(payment)
      return {
        success: true,
        refund_type: "none",
        refund_amount: 0,
        message: "No refund applicable due to cancellation policy"
      }
    end

    # Process refund with Stripe
    begin
      stripe_refund = Stripe::Refund.create(
        payment_intent: payment.stripe_payment_intent_id,
        amount: (policy[:amount] * 100).to_i # Convert to cents
      )

      # Update payment status
      ActiveRecord::Base.transaction do
        payment.update!(
          status: :refunded,
          refunded_at: Time.current
        )
      end

      # Send success notification
      NotificationService.notify_refund_processed(payment, policy[:type], policy[:amount])

      Rails.logger.info "Refund processed successfully: Payment #{payment.id}, Stripe Refund #{stripe_refund.id}"

      {
        success: true,
        refund_type: policy[:type],
        refund_amount: policy[:amount],
        stripe_refund_id: stripe_refund.id
      }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe refund failed for Payment #{payment.id}: #{e.message}"

      {
        success: false,
        error: e.message,
        refund_type: policy[:type]
      }
    rescue StandardError => e
      Rails.logger.error "Unexpected error during refund for Payment #{payment.id}: #{e.message}"

      {
        success: false,
        error: "An unexpected error occurred: #{e.message}"
      }
    end
  end

  # Calculate refund policy based on time until appointment
  #
  # @param payment [Payment] The payment to calculate refund for
  # @return [Hash] Policy hash with :type, :percentage, :amount keys
  def self.calculate_refund_policy(payment)
    return { type: "none", percentage: 0, amount: 0 } unless payment.appointment

    time_until_appointment = payment.appointment.start_time - Time.current

    # Past appointments are not refundable
    if time_until_appointment <= 0
      {
        type: "none",
        percentage: 0,
        amount: 0
      }
    # Full refund: 48 hours or more before appointment
    elsif time_until_appointment >= (FULL_REFUND_THRESHOLD - 1.minute)
      {
        type: "full",
        percentage: 100,
        amount: payment.amount
      }
    # Partial refund: Between 24-48 hours before appointment (inclusive of boundaries)
    elsif time_until_appointment > (PARTIAL_REFUND_THRESHOLD - 1.minute)
      {
        type: "partial",
        percentage: 50,
        amount: payment.amount * PARTIAL_REFUND_PERCENTAGE
      }
    # No refund: Less than 24 hours before appointment
    else
      {
        type: "none",
        percentage: 0,
        amount: 0
      }
    end
  end

  # Validate if payment is eligible for refund
  #
  # @param payment [Payment] The payment to validate
  # @return [Hash] Result hash with :success and optional :error keys
  def self.validate_payment_for_refund(payment)
    if payment.refunded?
      return {
        success: false,
        error: "Payment already refunded on #{payment.refunded_at.strftime('%B %d, %Y')}"
      }
    end

    if payment.pending?
      return {
        success: false,
        error: "Cannot refund pending payment. Payment must be succeeded first."
      }
    end

    if payment.failed?
      return {
        success: false,
        error: "Cannot refund failed payment."
      }
    end

    unless payment.appointment
      return {
        success: false,
        error: "Payment has no associated appointment."
      }
    end

    { success: true }
  end

  private_class_method :validate_payment_for_refund
end
