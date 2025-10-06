class Conversation < ApplicationRecord
  # Associations
  belongs_to :patient, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :appointment, optional: true
  has_many :messages, dependent: :destroy

  # Validations
  validates :patient_id, presence: true
  validates :provider_id, presence: true
  validate :participants_must_be_different

  # Scopes
  scope :for_user, ->(user) {
    where("patient_id = ? OR provider_id = ?", user.id, user.id)
  }
  scope :recent, -> { order(last_message_at: :desc) }
  scope :unarchived_for_patient, -> { where(archived_by_patient: false) }
  scope :unarchived_for_provider, -> { where(archived_by_provider: false) }

  # User-specific archive filtering
  scope :unarchived_for, ->(user) {
    if user.patient?
      where(patient_id: user.id, archived_by_patient: false)
        .or(where(provider_id: user.id, archived_by_provider: false))
    elsif user.provider?
      where(patient_id: user.id, archived_by_patient: false)
        .or(where(provider_id: user.id, archived_by_provider: false))
    else
      none
    end
  }

  scope :archived_for, ->(user) {
    if user.patient?
      where(patient_id: user.id, archived_by_patient: true)
        .or(where(provider_id: user.id, archived_by_provider: true))
    elsif user.provider?
      where(patient_id: user.id, archived_by_patient: true)
        .or(where(provider_id: user.id, archived_by_provider: true))
    else
      none
    end
  }

  # Instance methods

  # Get the other participant in the conversation
  def other_participant(user)
    user == patient ? provider : patient
  end

  # Get all participants
  def participants
    [patient, provider].compact
  end

  # Check if a user is a participant
  def participant?(user)
    user == patient || user == provider
  end

  # Update the last_message_at timestamp
  def touch_last_message
    update(last_message_at: Time.current)
  end

  # Increment unread count for the recipient (not the sender)
  def increment_unread_for(sender)
    if sender == patient
      increment!(:provider_unread_count)
    elsif sender == provider
      increment!(:patient_unread_count)
    end
  end

  # Reset unread count for a specific user
  def mark_as_read_for(user)
    if user == patient
      update(patient_unread_count: 0)
    elsif user == provider
      update(provider_unread_count: 0)
    end
  end

  # Convenience methods for marking as read by role
  def mark_as_read_for_patient
    update(patient_unread_count: 0)
  end

  def mark_as_read_for_provider
    update(provider_unread_count: 0)
  end

  # Get unread count for a specific user
  def unread_count_for(user)
    if user == patient
      patient_unread_count
    elsif user == provider
      provider_unread_count
    else
      0
    end
  end

  private

  # Custom validation: patient and provider must be different users
  def participants_must_be_different
    if patient_id.present? && provider_id.present? && patient_id == provider_id
      errors.add(:base, "Patient and provider must be different users")
    end
  end
end
