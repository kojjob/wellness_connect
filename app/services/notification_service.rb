class NotificationService
  # Create a notification for appointment booking
  def self.notify_appointment_booked(appointment)
    # Notify provider
    Notification.create!(
      user: appointment.provider,
      title: "New Appointment Booked",
      message: "#{appointment.patient.email} has booked an appointment with you for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')}",
      notification_type: "appointment_booked",
      action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
    )

    # Notify patient
    Notification.create!(
      user: appointment.patient,
      title: "Appointment Confirmed",
      message: "Your appointment with #{appointment.provider.email} has been confirmed for #{appointment.start_time.strftime('%B %d, %Y at %I:%M %p')}",
      notification_type: "appointment_booked",
      action_url: Rails.application.routes.url_helpers.appointment_path(appointment)
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
end

