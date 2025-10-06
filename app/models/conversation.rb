class Conversation < ApplicationRecord
  # Associations
  belongs_to :patient, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :appointment, optional: true
  has_many :messages, dependent: :destroy

  # Validations
  validates :patient_id, presence: true
  validates :provider_id, presence: true
  validate :patient_and_provider_must_be_different
  validate :appointment_participants_must_match, if: :appointment_id?

  # Scopes
  scope :active, -> { where(archived_by_patient: false, archived_by_provider: false) }
  scope :archived, -> { where("archived_by_patient = ? OR archived_by_provider = ?", true, true) }
  scope :with_unread, -> { where("patient_unread_count > 0 OR provider_unread_count > 0") }
  scope :appointment_specific, -> { where.not(appointment_id: nil) }
  scope :general, -> { where(appointment_id: nil) }
  scope :ordered, -> { order(last_message_at: :desc, created_at: :desc) }

  # Instance methods

  # Returns array of both participants
  def participants
    [ patient, provider ].compact
  end

  # Returns the other participant in the conversation
  # @param user [User] the user to find the other participant for
  # @return [User, nil] the other participant or nil if user is not a participant
  def other_participant(user)
    return provider if user == patient
    return patient if user == provider
    nil
  end

  # Marks all messages in conversation as read for the given user
  # @param user [User] the user marking messages as read
  def mark_as_read_for(user)
    if user == patient
      update(patient_unread_count: 0)
    elsif user == provider
      update(provider_unread_count: 0)
    end
  end

  # Returns unread message count for the given user
  # @param user [User] the user to check unread count for
  # @return [Integer] number of unread messages
  def unread_count_for(user)
    return patient_unread_count if user == patient
    return provider_unread_count if user == provider
    0
  end

  # Increments unread count for the recipient when sender sends a message
  # @param sender [User] the user who sent the message
  def increment_unread_for(sender)
    if sender == patient
      increment!(:provider_unread_count)
    elsif sender == provider
      increment!(:patient_unread_count)
    end
  end

  # Checks if user has unread messages in this conversation
  # @param user [User] the user to check
  # @return [Boolean] true if user has unread messages
  def has_unread_for?(user)
    unread_count_for(user) > 0
  end

  # Updates last_message_at timestamp
  def touch_last_message
    update(last_message_at: Time.current)
  end

  private

  # Custom validation: patient and provider must be different users
  def patient_and_provider_must_be_different
    if patient_id.present? && patient_id == provider_id
      errors.add(:provider_id, "cannot be the same as patient")
    end
  end

  # Custom validation: if appointment-scoped, participants must match appointment
  def appointment_participants_must_match
    return unless appointment

    unless appointment.patient_id == patient_id && appointment.provider_id == provider_id
      errors.add(:base, "Conversation participants must match appointment participants")
    end
  end
end
