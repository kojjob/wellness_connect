class Appointment < ApplicationRecord
  belongs_to :patient, class_name: "User", counter_cache: :appointments_as_patient_count
  belongs_to :provider, class_name: "User", counter_cache: :appointments_as_provider_count
  belongs_to :service, counter_cache: true

  has_one :payment, dependent: :destroy
  has_one :consultation_note, dependent: :destroy

  enum :status, {
    scheduled: 0,
    completed: 1,
    cancelled_by_patient: 2,
    cancelled_by_provider: 3,
    no_show: 4,
    payment_pending: 5,
    cancelled_by_system: 6
  }, default: :payment_pending
end
