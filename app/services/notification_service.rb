class NotificationService
  # Create a notification for appointment booking
  def self.notify_appointment_booked(appointment)
    # Notify provider
    if can_notify?(appointment.provider, "appointment_booked")
      title = "New Appointment Booked"
      message = "#{appointment.patient.email} has booked an appointment with you for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')}"

      Notification.create!(
        user: appointment.provider,
        title: title,
        message: message,
        notification_type: "appointment_booked",
        action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
      )

      # Send email if enabled
      send_email(appointment.provider, "appointment_booked", title, message)
    end

    # Notify patient
    if can_notify?(appointment.patient, "appointment_booked")
      title = "Appointment Confirmed"
      message = "Your appointment with #{appointment.provider.email} has been confirmed for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')}"

      Notification.create!(
        user: appointment.patient,
        title: title,
        message: message,
        notification_type: "appointment_booked",
        action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
      )

      # Send email if enabled
      send_email(appointment.patient, "appointment_booked", title, message)
    end
  end

  # Create a notification for appointment cancellation
  def self.notify_appointment_cancelled(appointment, cancelled_by)
    other_user = cancelled_by == appointment.patient ? appointment.provider : appointment.patient

    if can_notify?(other_user, "appointment_cancelled")
      Notification.create!(
        user: other_user,
        title: "Appointment Cancelled",
        message: "Your appointment scheduled for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')} has been cancelled",
        notification_type: "appointment_cancelled",
        action_url: Rails.application.routes.url_helpers.appointments_path
      )
    end
  end

  # Create a notification for appointment reminder (24 hours before)
  def self.notify_appointment_reminder(appointment)
    # Notify patient
    if can_notify?(appointment.patient, "appointment_reminder")
      title = "Appointment Reminder"
      message = "You have an appointment with #{appointment.provider.email} tomorrow at #{appointment.start_time.strftime('%I:%M %p')}"

      Notification.create!(
        user: appointment.patient,
        title: title,
        message: message,
        notification_type: "appointment_reminder",
        action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
      )

      # Send email if enabled
      send_email(appointment.patient, "appointment_reminder", title, message)
    end

    # Notify provider
    if can_notify?(appointment.provider, "appointment_reminder")
      title = "Appointment Reminder"
      message = "You have an appointment with #{appointment.patient.email} tomorrow at #{appointment.start_time.strftime('%I:%M %p')}"

      Notification.create!(
        user: appointment.provider,
        title: title,
        message: message,
        notification_type: "appointment_reminder",
        action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
      )

      # Send email if enabled
      send_email(appointment.provider, "appointment_reminder", title, message)
    end
  end

  # Create a notification for payment received
  def self.notify_payment_received(payment)
    if payment.appointment.present? && can_notify?(payment.appointment.provider, "payment_received")
      Notification.create!(
        user: payment.appointment.provider,
        title: "Payment Received",
        message: "You received a payment of $#{payment.amount} for your appointment with #{payment.payer.email}",
        notification_type: "payment_received",
        action_url: Rails.application.routes.url_helpers.appointment_path(payment.appointment)
      )
    end
  end

  # Create a notification for payment failed
  def self.notify_payment_failed(payment)
    if can_notify?(payment.payer, "payment_failed")
      Notification.create!(
        user: payment.payer,
        title: "Payment Failed",
        message: "Your payment of $#{payment.amount} could not be processed. Please update your payment method.",
        notification_type: "payment_failed",
        action_url: Rails.application.routes.url_helpers.appointments_path
      )
    end
  end

  # Create a notification for profile approval
  def self.notify_profile_approved(provider_profile)
    if can_notify?(provider_profile.user, "profile_approved")
      Notification.create!(
        user: provider_profile.user,
        title: "Profile Approved",
        message: "Congratulations! Your provider profile has been approved and is now live.",
        notification_type: "profile_approved",
        action_url: Rails.application.routes.url_helpers.provider_profile_path(provider_profile)
      )
    end
  end

  # Create a notification for new review
  def self.notify_new_review(provider_profile, reviewer)
    if can_notify?(provider_profile.user, "new_review")
      Notification.create!(
        user: provider_profile.user,
        title: "New Review Received",
        message: "#{reviewer.email} left a review on your profile",
        notification_type: "new_review",
        action_url: Rails.application.routes.url_helpers.provider_profile_path(provider_profile)
      )
    end
  end

  # Create a system announcement
  def self.notify_system_announcement(user, title, message)
    if can_notify?(user, "system_announcement")
      Notification.create!(
        user: user,
        title: title,
        message: message,
        notification_type: "system_announcement"
      )
    end
  end

  # Broadcast all announcements to all users
  def self.broadcast_announcement(title, message)
    User.find_each do |user|
      notify_system_announcement(user, title, message)
    end
  end

  # Create a notification for refund processed
  def self.notify_refund_processed(payment, refund_type, refund_amount)
    return unless can_notify?(payment.payer, "refund_processed")

    refund_type_label = refund_type == "full" ? "full" : "partial (50%)"

    Notification.create!(
      user: payment.payer,
      title: "Refund Processed",
      message: "Your #{refund_type_label} refund of $#{refund_amount.round(2)} has been processed and will appear in your account within 5-10 business days.",
      notification_type: "refund_processed",
      action_url: Rails.application.routes.url_helpers.payments_path
    )
  end

  # Create a notification for no refund policy
  def self.notify_no_refund_policy(payment)
    if can_notify?(payment.payer, "no_refund")
      Notification.create!(
        user: payment.payer,
        title: "Cancellation Policy Applied",
        message: "Your appointment was cancelled less than 24 hours before the scheduled time. Per our cancellation policy, no refund is available.",
        notification_type: "no_refund",
        action_url: Rails.application.routes.url_helpers.appointments_path
      )
    end
  end

  # Create a notification for new message
  def self.notify_new_message(message)
    recipient = message.recipient
    return unless recipient.present?
    return unless can_notify?(recipient, "new_message")

    sender = message.sender
    conversation = message.conversation

    # Truncate message content for notification
    message_preview = message.content.present? ? message.content.truncate(100) : "[Attachment]"

    title = "New Message from #{sender.full_name}"
    notification_message = "#{sender.full_name}: #{message_preview}"

    Notification.create!(
      user: recipient,
      title: title,
      message: notification_message,
      notification_type: "new_message",
      action_url: Rails.application.routes.url_helpers.conversation_path(conversation)
    )

    # Send email if enabled
    send_email(recipient, "new_message", title, notification_message)
  end

  private

  # Check if a user's preferences allow notification of a specific type
  def self.can_notify?(user, notification_type)
    # Get or create notification preferences
    preferences = user.notification_preference || user.create_notification_preference!

    # Check if in-app notifications are enabled for this type
    preferences.in_app_enabled_for?(notification_type)
  end

  # Check if a user's preferences allow email notification of a specific type
  def self.can_email_notify?(user, notification_type)
    # Get or create notification preferences
    preferences = user.notification_preference || user.create_notification_preference!

    # Check if email notifications are enabled for this type
    preferences.email_enabled_for?(notification_type)
  end

  # Send email notification if user has email notifications enabled
  def self.send_email(user, notification_type, title, message, attachments = [])
    return unless can_email_notify?(user, notification_type)

    # Map notification types to mailer methods
    mailer_method = case notification_type
    when "appointment_booked", "appointment_reminder"
      :appointment_booked
    when "appointment_cancelled"
      :appointment_cancelled
    when "payment_received"
      :payment_received
    when "payment_failed"
      :payment_failed
    when "refund_processed", "no_refund"
      :refund_processed
    when "profile_approved"
      :profile_approved
    when "new_review"
      :new_review
    when "system_announcement"
      :system_announcement
    else
      :notification
    end

    # Send email asynchronously
    NotificationMailer.public_send(mailer_method, user, title, message).deliver_later
  rescue => e
    Rails.logger.error "Failed to send email notification: #{e.message}"
    # Don't raise error - email failure shouldn't break notification creation
  end
end
