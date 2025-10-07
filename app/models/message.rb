class Message < ApplicationRecord
  # Associations
  belongs_to :conversation
  belongs_to :sender, class_name: "User"
  has_one_attached :attachment

  # Encryption
  encrypts :content

  # Validations
  validates :conversation_id, presence: true
  validates :sender_id, presence: true
  validate :content_or_attachment_present
  validate :sender_must_be_participant
  validate :attachment_validation

  # Enums
  enum :message_type, { text: 0, file: 1, image: 2, system: 3 }, default: :text

  # Scopes
  scope :ordered, -> { order(created_at: :asc) }
  scope :unread, -> { where(read_at: nil) }
  scope :from_sender, ->(sender) { where(sender: sender) }
  scope :by_type, ->(type) { where(message_type: type) }

  # Callbacks
  before_update :set_edited_timestamp, if: :content_changed?
  after_create :update_conversation_timestamp
  after_create :increment_recipient_unread_count
  after_create :send_notification_to_recipient
  after_create_commit :broadcast_message

  # Instance methods

  # Mark this message as read
  def mark_as_read
    update(read_at: Time.current) if read_at.nil?
  end

  # Check if message has been read
  def read?
    read_at.present?
  end

  # Check if message can be edited (within 15 minutes of creation)
  def editable?
    created_at > 15.minutes.ago
  end

  # Get the recipient of this message (the other participant)
  def recipient
    conversation.other_participant(sender)
  end

  private

  # Custom validation: message must have either content or attachment
  def content_or_attachment_present
    if content.blank? && !attachment.attached?
      errors.add(:base, "Message must have either content or attachment")
    end
  end

  # Custom validation: sender must be a participant in the conversation
  # (admins can send messages in any conversation for moderation)
  def sender_must_be_participant
    return unless conversation && sender
    return if sender.admin?  # Admins can send messages in any conversation

    unless conversation.participants.include?(sender)
      errors.add(:sender, "must be a participant in the conversation")
    end
  end

  # Custom validation: attachment file type and size validation
  def attachment_validation
    return unless attachment.attached?

    # File type validation
    allowed_image_types = %w[image/jpeg image/jpg image/png image/webp]
    allowed_document_types = %w[application/pdf]
    allowed_types = allowed_image_types + allowed_document_types

    unless allowed_types.include?(attachment.blob.content_type)
      errors.add(:attachment, "must be a JPEG, PNG, WebP image or PDF document")
    end

    # File size validation
    if allowed_image_types.include?(attachment.blob.content_type)
      if attachment.blob.byte_size > 10.megabytes
        errors.add(:attachment, "image size must be less than 10MB")
      end
    elsif attachment.blob.content_type == "application/pdf"
      if attachment.blob.byte_size > 20.megabytes
        errors.add(:attachment, "PDF size must be less than 20MB")
      end
    end
  end

  # Callback: update conversation's last_message_at timestamp
  def update_conversation_timestamp
    conversation.touch_last_message
  end

  # Callback: increment unread count for the recipient
  def increment_recipient_unread_count
    conversation.increment_unread_for(sender)
  end

  # Callback: send notification to recipient
  def send_notification_to_recipient
    return unless recipient.present?
    return if message_type == "system" # Don't notify for system messages

    # Create notification for the recipient
    NotificationService.notify_new_message(self)
  end

  # Callback: broadcast message to conversation channel
  def broadcast_message
    # TODO: Implement in Phase 2 when we add Action Cable channels
    # broadcast_append_to [conversation, "messages"], target: "messages"
  end

  # Callback: set edited_at timestamp when content changes
  def set_edited_timestamp
    self.edited_at = Time.current
  end
end
