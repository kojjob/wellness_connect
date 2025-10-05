class Notification < ApplicationRecord
  belongs_to :user

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
    profile_approved
    new_review
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
end
