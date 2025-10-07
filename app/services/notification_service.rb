class NotificationService
  # Create a notification for appointment booking
  def self.notify_appointment_booked(appointment)
    # Notify provider
    create_notification(
      user: appointment.provider,
      actor: appointment.patient,
      notifiable: appointment,
      title: "New Appointment Booked",
      message: "#{appointment.patient.full_name} has booked an appointment with you for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')}",
      notification_type: "appointment_booked",
      action_url: Rails.application.routes.url_helpers.appointment_path(appointment),
      send_email: true,
      mailer_method: :provider_booking_notification,
      mailer_args: [appointment]
    )

    # Notify patient
    create_notification(
      user: appointment.patient,
      actor: appointment.provider,
      notifiable: appointment,
      title: "Appointment Confirmed",
      message: "Your appointment with #{appointment.provider.full_name} has been confirmed for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')}",
      notification_type: "appointment_booked",
      action_url: Rails.application.routes.url_helpers.appointment_path(appointment),
      send_email: true,
      mailer_method: :booking_confirmation,
      mailer_args: [appointment]
    )
  end

  # Create a notification for appointment cancellation
  def self.notify_appointment_cancelled(appointment, cancelled_by)
    other_user = cancelled_by == appointment.patient ? appointment.provider : appointment.patient

    Notification.create!(
      user: other_user,
      title: "Appointment Cancelled",
      message: "Your appointment scheduled for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')} has been cancelled",
      notification_type: "appointment_cancelled",
      action_url: Rails.application.routes.url_helpers.appointments_path
    )
  end

  # Create a notification for appointment reminder (24 hours before)
  def self.notify_appointment_reminder(appointment)
    # Notify patient
    Notification.create!(
      user: appointment.patient,
      title: "Appointment Reminder",
      message: "You have an appointment with #{appointment.provider.email} tomorrow at #{appointment.start_time.strftime('%I:%M %p')}",
      notification_type: "appointment_reminder",
      action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
    )

    # Notify provider
    Notification.create!(
      user: appointment.provider,
      title: "Appointment Reminder",
      message: "You have an appointment with #{appointment.patient.email} tomorrow at #{appointment.start_time.strftime('%I:%M %p')}",
      notification_type: "appointment_reminder",
      action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
    )
  end

  # Create a notification for payment received
  def self.notify_payment_received(payment)
    if payment.appointment.present?
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
    Notification.create!(
      user: payment.payer,
      title: "Payment Failed",
      message: "Your payment of $#{payment.amount} could not be processed. Please update your payment method.",
      notification_type: "payment_failed",
      action_url: Rails.application.routes.url_helpers.appointments_path
    )
  end

  # Create a notification for profile approval
  def self.notify_profile_approved(provider_profile)
    Notification.create!(
      user: provider_profile.user,
      title: "Profile Approved",
      message: "Congratulations! Your provider profile has been approved and is now live.",
      notification_type: "profile_approved",
      action_url: Rails.application.routes.url_helpers.provider_profile_path(provider_profile)
    )
  end

  # Create a notification for new review
  def self.notify_new_review(provider_profile, reviewer)
    Notification.create!(
      user: provider_profile.user,
      title: "New Review Received",
      message: "#{reviewer.email} left a review on your profile",
      notification_type: "new_review",
      action_url: Rails.application.routes.url_helpers.provider_profile_path(provider_profile)
    )
  end

  # Create a system announcement
  def self.notify_system_announcement(user, title, message)
    Notification.create!(
      user: user,
      title: title,
      message: message,
      notification_type: "system_announcement"
    )
  end

  # Broadcast all announcements to all users
  def self.broadcast_announcement(title, message)
    User.find_each do |user|
      notify_system_announcement(user, title, message)
    end
  end

  # Create a notification for refund processed
  def self.notify_refund_processed(payment, refund_type, refund_amount)
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
    Notification.create!(
      user: payment.payer,
      title: "Cancellation Policy Applied",
      message: "Your appointment was cancelled less than 24 hours before the scheduled time. Per our cancellation policy, no refund is available.",
      notification_type: "no_refund",
      action_url: Rails.application.routes.url_helpers.appointments_path
    )
  end

  # Create notification for new message
  def self.notify_message_received(message, recipient)
    conversation = message.conversation
    sender = message.sender

    create_notification(
      user: recipient,
      actor: sender,
      notifiable: message,
      title: "New Message",
      message: "#{sender.full_name}: #{message.content.truncate(50)}",
      notification_type: "message_received",
      action_url: Rails.application.routes.url_helpers.conversation_path(conversation),
      send_email: false  # Messages are real-time, skip email
    )
  end

  private

  # Core method to create notification with email and broadcasting
  def self.create_notification(
    user:,
    title:,
    message:,
    notification_type:,
    actor: nil,
    notifiable: nil,
    action_url: nil,
    send_email: false,
    mailer_method: nil,
    mailer_args: []
  )
    # Create in-app notification
    notification = Notification.create!(
      user: user,
      actor: actor,
      notifiable: notifiable,
      notification_type: notification_type,
      title: title,
      message: message,
      action_url: action_url
    )

    # Send email if requested and mailer method provided
    if send_email && mailer_method.present?
      begin
        AppointmentMailer.public_send(mailer_method, *mailer_args).deliver_later
        notification.mark_as_delivered!
      rescue => e
        Rails.logger.error("Failed to send notification email: #{e.message}")
      end
    end

    # Broadcast to user's notification stream for real-time updates
    broadcast_notification(notification) if defined?(Turbo)

    notification
  end

  # Broadcast notification to user's Turbo Stream
  def self.broadcast_notification(notification)
    Turbo::StreamsChannel.broadcast_append_to(
      "notifications_#{notification.user_id}",
      target: "notifications",
      partial: "notifications/notification",
      locals: { notification: notification }
    )
  rescue => e
    Rails.logger.error("Failed to broadcast notification: #{e.message}")
  end
end
