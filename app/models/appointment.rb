class Appointment < ApplicationRecord
  belongs_to :patient, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :service
  belongs_to :availability, optional: true

  has_one :payment, dependent: :destroy
  has_one :consultation_note, dependent: :destroy
  has_one :conversation, dependent: :nullify # Conversation can exist without appointment

  # Validations
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :patient_id, presence: true
  validates :provider_id, presence: true
  validates :service_id, presence: true
  validates :status, presence: true

  validate :end_time_after_start_time
  validate :patient_and_provider_different
  validate :start_time_in_future, on: :create

  enum :status, {
    scheduled: 0,
    completed: 1,
    cancelled_by_patient: 2,
    cancelled_by_provider: 3,
    no_show: 4,
    payment_pending: 5
  }, default: :payment_pending

  # Scopes
  scope :upcoming, -> { where(status: [ :scheduled, :payment_pending ]).where("start_time > ?", Time.current) }
  scope :past, -> { where("start_time < ?", Time.current) }
  scope :active, -> { where(status: [ :scheduled, :payment_pending ]) }
  scope :for_date, ->(date) { where(start_time: date.beginning_of_day..date.end_of_day) }

  # Instance methods
  def duration_minutes
    return 0 unless start_time && end_time
    ((end_time - start_time) / 60).to_i
  end

  def cancellable?
    scheduled? || payment_pending?
  end

  def cancelled?
    cancelled_by_patient? || cancelled_by_provider?
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def patient_and_provider_different
    return unless patient_id && provider_id
    if patient_id == provider_id
      errors.add(:patient_id, "cannot be the same as provider")
    end
  end

  def start_time_in_future
    return unless start_time
    if start_time < Time.current
      errors.add(:start_time, "must be in the future")
    end
  end
end
