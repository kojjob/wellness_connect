class Appointment < ApplicationRecord
  belongs_to :patient, class_name: 'User'
  belongs_to :provider, class_name: 'User'
  belongs_to :service

  has_one :payment, dependent: :destroy
  has_one :consultation_note, dependent: :destroy

  enum :status, {
    scheduled: 0,
    completed: 1,
    cancelled_by_patient: 2,
    cancelled_by_provider: 3,
    no_show: 4
  }, default: :scheduled
end
