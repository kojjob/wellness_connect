class Appointment < ApplicationRecord
  belongs_to :patient, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :service
  belongs_to :availability, optional: true

  has_one :payment, dependent: :destroy
  has_one :consultation_note, dependent: :destroy
  has_one :conversation, dependent: :nullify # Conversation can exist without appointment

  enum :status, {
    scheduled: 0,
    completed: 1,
    cancelled_by_patient: 2,
    cancelled_by_provider: 3,
    no_show: 4,
    payment_pending: 5
  }, default: :payment_pending
end
