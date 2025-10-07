class NotificationPreference < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, presence: true, uniqueness: true

  # Check if email notifications are enabled for a specific type
  def email_enabled_for?(notification_type)
    case notification_type.to_s
    when /appointment/
      email_appointments
    when /message/
      email_messages
    when /payment|refund/
      email_payments
    when /system|profile|review/
      email_system
    else
      true # Default to enabled for unknown types
    end
  end

  # Check if in-app notifications are enabled for a specific type
  def in_app_enabled_for?(notification_type)
    case notification_type.to_s
    when /appointment/
      in_app_appointments
    when /message/
      in_app_messages
    when /payment|refund/
      in_app_payments
    when /system|profile|review/
      in_app_system
    else
      true # Default to enabled for unknown types
    end
  end

  # Check if any email notifications are enabled
  def email_notifications_enabled?
    email_appointments || email_messages || email_payments || email_system
  end

  # Check if any in-app notifications are enabled
  def in_app_notifications_enabled?
    in_app_appointments || in_app_messages || in_app_payments || in_app_system
  end

  # Disable all email notifications
  def disable_all_email!
    update(
      email_appointments: false,
      email_messages: false,
      email_payments: false,
      email_system: false
    )
  end

  # Enable all email notifications
  def enable_all_email!
    update(
      email_appointments: true,
      email_messages: true,
      email_payments: true,
      email_system: true
    )
  end

  # Disable all in-app notifications
  def disable_all_in_app!
    update(
      in_app_appointments: false,
      in_app_messages: false,
      in_app_payments: false,
      in_app_system: false
    )
  end

  # Enable all in-app notifications
  def enable_all_in_app!
    update(
      in_app_appointments: true,
      in_app_messages: true,
      in_app_payments: true,
      in_app_system: true
    )
  end
end
