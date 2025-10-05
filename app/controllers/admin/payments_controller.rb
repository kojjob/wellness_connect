module Admin
  class PaymentsController < BaseController
    before_action :set_payment, only: [ :show ]
    before_action :authorize_payment

    def index
      @payments = policy_scope([ :admin, Payment ]).includes(:payer, :appointment).order(created_at: :desc)

      # Filter by status
      if params[:status].present? && Payment.statuses.keys.include?(params[:status])
        @payments = @payments.where(status: params[:status])
      end

      # Filter by date range
      if params[:start_date].present?
        @payments = @payments.where("created_at >= ?", Date.parse(params[:start_date]).beginning_of_day)
      end

      if params[:end_date].present?
        @payments = @payments.where("created_at <= ?", Date.parse(params[:end_date]).end_of_day)
      end

      # Search by payer name or Stripe payment intent ID
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @payments = @payments.joins(:payer).where(
          "users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ? OR payments.stripe_payment_intent_id ILIKE ?",
          search_term, search_term, search_term, search_term
        )
      end

      @payments = @payments.page(params[:page]).per(20)
    end

    def show
      # Instance variable set by before_action
    end

    private

    def set_payment
      @payment = Payment.find(params[:id])
    end

    def authorize_payment
      if @payment
        authorize [ :admin, @payment ]
      else
        authorize [ :admin, Payment ]
      end
    end
  end
end
