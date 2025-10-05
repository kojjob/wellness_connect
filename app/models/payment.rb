class Payment < ApplicationRecord
  belongs_to :payer, class_name: "User"
  belongs_to :appointment, optional: true

  enum :status, {
    pending: 0,
    succeeded: 1,
    failed: 2,
    refunded: 3
  }, default: :pending
end
