class Payment < ApplicationRecord
  belongs_to :payer, class_name: "User"
  belongs_to :appointment, optional: true

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, format: { with: /\A[A-Z]{3}\z/, message: "must be a 3-letter currency code" }
  validates :status, presence: true
  validates :stripe_payment_intent_id, presence: true, if: :requires_stripe_id?
  validates :stripe_payment_intent_id, uniqueness: true, allow_nil: true
  validates :payer_id, presence: true

  validate :refund_amount_not_exceed_original

  enum :status, {
    pending: 0,
    succeeded: 1,
    failed: 2,
    refunded: 3
  }, default: :pending

  # Scopes
  scope :successful, -> { where(status: :succeeded) }
  scope :pending_payments, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_period, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Instance methods
  def refundable?
    succeeded? && stripe_payment_intent_id.present?
  end

  def formatted_amount
    format("$%.2f", amount)
  end

  def paid?
    succeeded?
  end

  private

  def requires_stripe_id?
    succeeded? || refunded?
  end

  def refund_amount_not_exceed_original
    return unless refunded_amount.present? && amount.present?
    return if refunded_amount <= amount

    errors.add(:refunded_amount, "cannot exceed the original amount")
  end
end
