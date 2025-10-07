class Notification < ApplicationRecord
  # Associations
  belongs_to :user  # recipient of the notification
  belongs_to :actor, class_name: "User", optional: true  # who triggered the notification
  belongs_to :notifiable, polymorphic: true, optional: true  # what entity is this about

  # Broadcast new notifications via Turbo Streams
  after_create_commit -> { broadcast_notification }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :delivered, -> { where.not(delivered_at: nil) }
  scope :undelivered, -> { where(delivered_at: nil) }
  scope :for_notifiable, ->(notifiable) { where(notifiable: notifiable) }

  # Notification types
  TYPES = %w[
    appointment_booked
    appointment_cancelled
    appointment_reminder
    appointment_updated
    appointment_completed
    message_received
    payment_received
    payment_failed
    refund_processed
    no_refund
    profile_approved
    new_review
    new_message
    system_announcement
  ].freeze

  # Validations
  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, inclusion: { in: TYPES }

  # Mark notification as read
  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  # Mark as delivered (for email tracking)
  def mark_as_delivered!
    update(delivered_at: Time.current) unless delivered?
  end

  # Check if notification is read
  def read?
    read_at.present?
  end

  # Check if notification is unread
  def unread?
    !read?
  end

  private

  # Broadcast notification to user's stream
  def broadcast_notification
    broadcast_prepend_to(
      "user_#{user_id}_notifications",
      partial: "notifications/notification",
      locals: { notification: self },
      target: "notifications"
    )
  end
end
