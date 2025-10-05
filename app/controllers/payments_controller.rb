class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :create ]
  before_action :authorize_appointment_access, only: [ :create ]

  def index
    # Build base query based on user role
    @payments = if current_user.provider?
      # Providers see payments they've received
      Payment.joins(:appointment)
             .where(appointments: { provider_id: current_user.id })
    else
      # Patients/clients see payments they've made
      Payment.where(payer: current_user)
    end

    # Apply status filter if provided
    if params[:status].present? && Payment.statuses.keys.include?(params[:status])
      @payments = @payments.where(status: params[:status])
    end

    # Apply date range filter if provided
    if params[:start_date].present?
      @payments = @payments.where("payments.created_at >= ?", params[:start_date])
    end

    if params[:end_date].present?
      @payments = @payments.where("payments.created_at <= ?", params[:end_date])
    end

    # Order by most recent first and paginate
    @payments = @payments.includes(:payer, appointment: [:patient, :provider, :service])
                        .order(created_at: :desc)
                        .page(params[:page]).per(20)
  end

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
    @payment = Payment.find(params[:id])

    # In production, this would be handled by Stripe webhooks
    # This endpoint is here for testing and manual payment confirmation if needed
    render json: { status: "confirmation_endpoint_available" }, status: :ok
  end

  private

  def set_appointment
    @appointment = Appointment.find(payment_params[:appointment_id])
  end

  def authorize_appointment_access
    unless @appointment.patient == current_user
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end

  def payment_params
    params.require(:payment).permit(:appointment_id, :amount)
  end
end
