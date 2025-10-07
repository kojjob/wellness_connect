class NotificationMailer < ApplicationMailer
  default from: "noreply@wellnessconnect.com"

  # Generic notification email
  def notification(user, title, message, attachments_data = [])
    @user = user
    @title = title
    @message = message
    @notification_type = "general"

    # Add attachments if provided
    attachments_data.each do |attachment|
      attachments[attachment[:filename]] = attachment[:content]
    end

    mail(
      to: user.email,
      subject: title
    )
  end

  # Appointment booked notification
  def appointment_booked(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "appointment"

    mail(
      to: user.email,
      subject: title
    )
  end

  # Appointment cancelled notification
  def appointment_cancelled(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "appointment"

    mail(
      to: user.email,
      subject: title
    )
  end

  # Appointment reminder notification
  def appointment_reminder(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "appointment"

    mail(
      to: user.email,
      subject: title
    )
  end

  # Payment received notification
  def payment_received(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "payment"

    mail(
      to: user.email,
      subject: title
    )
  end

  # Payment failed notification
  def payment_failed(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "payment"

    mail(
      to: user.email,
      subject: title
    )
  end

  # Refund processed notification
  def refund_processed(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "payment"

    mail(
      to: user.email,
      subject: title
    )
  end

  # Profile approved notification
  def profile_approved(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "profile"

    mail(
      to: user.email,
      subject: title
    )
  end

  # New review notification
  def new_review(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "review"

    mail(
      to: user.email,
      subject: title
    )
  end

  # System announcement notification
  def system_announcement(user, title, message)
    @user = user
    @title = title
    @message = message
    @notification_type = "system"

    mail(
      to: user.email,
      subject: title
    )
  end
end
