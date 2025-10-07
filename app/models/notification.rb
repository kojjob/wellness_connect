class Notification < ApplicationRecord
  belongs_to :user

  # Broadcast new notifications via Turbo Streams
  after_create_commit -> { broadcast_notification }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(10) }

  # Notification types
  TYPES = %w[
    appointment_booked
    appointment_cancelled
    appointment_reminder
    payment_received
    payment_failed
    refund_processed
    no_refund
    profile_approved
    new_review
    new_message
    system_announcement
  ].freeze

  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, inclusion: { in: TYPES }

  # Mark notification as read
  def mark_as_read!
    update(read_at: Time.current) unless read?
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
