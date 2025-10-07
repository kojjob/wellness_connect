class Notification < ApplicationRecord
  # Associations
  belongs_to :user  # recipient of the notification
  belongs_to :actor, class_name: "User", optional: true  # who triggered the notification
  belongs_to :notifiable, polymorphic: true, optional: true  # what entity is this about

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

  # Check if email was delivered
  def delivered?
    delivered_at.present?
  end

  # Get actor name or "System" for system notifications
  def actor_name
    actor&.full_name || "System"
  end
end
