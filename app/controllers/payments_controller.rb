class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [ :create ]
  before_action :authorize_appointment_access, only: [ :create ]

  def index
    # Build base query based on user role
    base_payments = if current_user.provider?
      # Providers see payments they've received
      Payment.joins(:appointment)
             .where(appointments: { provider_id: current_user.id })
    else
      # Patients/clients see payments they've made
      Payment.where(payer: current_user)
    end

    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      base_payments = base_payments.joins(appointment: [ :provider, :service ])
                                   .where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR services.name ILIKE ? OR payments.stripe_payment_intent_id ILIKE ?",
                                          search_term, search_term, search_term, search_term)
    end

    # Apply status filter if provided
    if params[:status].present? && Payment.statuses.keys.include?(params[:status])
      base_payments = base_payments.where(status: params[:status])
    end

    # Apply date range filter with presets
    if params[:date_range].present?
      case params[:date_range]
      when "last_7_days"
        base_payments = base_payments.where("payments.created_at >= ?", 7.days.ago)
      when "last_30_days"
        base_payments = base_payments.where("payments.created_at >= ?", 30.days.ago)
      when "last_3_months"
        base_payments = base_payments.where("payments.created_at >= ?", 3.months.ago)
      when "last_year"
        base_payments = base_payments.where("payments.created_at >= ?", 1.year.ago)
      when "custom"
        if params[:start_date].present?
          base_payments = base_payments.where("payments.created_at >= ?", params[:start_date])
        end
        if params[:end_date].present?
          base_payments = base_payments.where("payments.created_at <= ?", params[:end_date])
        end
      end
    end

    # Apply sorting
    @payments = case params[:sort]
    when "amount_high"
                  base_payments.order(amount: :desc)
    when "amount_low"
                  base_payments.order(amount: :asc)
    when "oldest"
                  base_payments.order(created_at: :asc)
    else # 'newest' or default
                  base_payments.order(created_at: :desc)
    end

    # Calculate statistics before pagination - optimized with single query
    stats = base_payments.group(:status).select("status, COUNT(*) as count, SUM(amount) as total_amount").to_a
    stats_hash = stats.each_with_object({}) do |stat, hash|
      hash[stat.status] = { count: stat.count, amount: stat.total_amount || 0 }
    end

    @total_spent = stats_hash["succeeded"]&.dig(:amount) || 0
    @pending_amount = stats_hash["pending"]&.dig(:amount) || 0
    @refunded_amount = stats_hash["refunded"]&.dig(:amount) || 0
    @total_payments_count = stats.sum(&:count)
    @succeeded_count = stats_hash["succeeded"]&.dig(:count) || 0
    @pending_count = stats_hash["pending"]&.dig(:count) || 0
    @failed_count = stats_hash["failed"]&.dig(:count) || 0
    @refunded_count = stats_hash["refunded"]&.dig(:count) || 0

    # Monthly spending (last 6 months) - use SQL GROUP BY for better performance
    @monthly_spending = base_payments.where(status: :succeeded)
                                     .where("payments.paid_at >= ?", 6.months.ago)
                                     .group("DATE_TRUNC('month', COALESCE(payments.paid_at, payments.created_at))")
                                     .sum(:amount)
                                     .transform_keys { |date| date.strftime("%Y-%m") }
                                     .sort.to_h

    # Recent transactions for sidebar (last 5)
    @recent_transactions = base_payments.includes(:payer, appointment: [ :patient, :provider, :service ])
                                       .order(created_at: :desc)
                                       .limit(5)

    # Paginate main list
    @payments = @payments.includes(:payer, appointment: [ :patient, :provider, :service ])
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
