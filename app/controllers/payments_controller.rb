class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :create ]
  before_action :authorize_appointment_access, only: [ :create ]
  before_action :set_payment, only: [ :confirm ]
  before_action :authorize_payment_access, only: [ :confirm ]

  def create
    begin
      # Create Stripe Payment Intent
      payment_intent = Stripe::PaymentIntent.create(
        amount: (payment_params[:amount].to_f * 100).to_i, # Stripe uses cents
        currency: "usd",
        metadata: {
          appointment_id: @appointment.id,
          patient_id: current_user.id
        }
      )

      # Create Payment record
      @payment = Payment.create!(
        payer: current_user,
        appointment: @appointment,
        amount: payment_params[:amount],
        currency: "USD",
        status: :pending,
        stripe_payment_intent_id: payment_intent.id
      )

      render json: {
        client_secret: payment_intent.client_secret,
        payment_intent_id: payment_intent.id,
        payment_id: @payment.id
      }, status: :ok
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def confirm
    # Validate payment_intent_id parameter
    unless params[:payment_intent_id].present?
      return render json: {
        status: "error",
        message: "Payment intent ID is required"
      }, status: :unprocessable_entity
    end

    # Verify payment_intent_id matches
    unless @payment.stripe_payment_intent_id == params[:payment_intent_id]
      return render json: {
        status: "error",
        message: "Payment intent ID does not match"
      }, status: :unprocessable_entity
    end

    # Check if payment is in a valid state for confirmation
    if @payment.failed?
      return render json: {
        status: "error",
        message: "Cannot confirm a failed payment"
      }, status: :unprocessable_entity
    end

    # Handle idempotency - if already succeeded, just return success
    if @payment.succeeded?
      return render json: {
        status: "succeeded",
        payment: payment_response_data
      }, status: :ok
    end

    # Process payment confirmation
    begin
      ActiveRecord::Base.transaction do
        # Update payment status
        @payment.update!(
          status: :succeeded,
          paid_at: Time.current
        )

        # Update appointment status to scheduled
        @payment.appointment.update!(status: :scheduled) if @payment.appointment.present?
      end

      render json: {
        status: "succeeded",
        payment: payment_response_data
      }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: {
        status: "error",
        message: "Failed to confirm payment: #{e.message}"
      }, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(payment_params[:appointment_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Appointment not found" }, status: :not_found
  end

  def set_payment
    @payment = Payment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Payment not found" }, status: :not_found
  end

  def authorize_appointment_access
    unless @appointment.patient == current_user
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end

  def authorize_payment_access
    unless @payment.payer == current_user
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end

  def payment_response_data
    {
      id: @payment.id,
      amount: @payment.amount,
      currency: @payment.currency,
      status: @payment.status,
      paid_at: @payment.paid_at,
      appointment_id: @payment.appointment_id
    }
  end

  def payment_params
    params.require(:payment).permit(:appointment_id, :amount)
  end
end
