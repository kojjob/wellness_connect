# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/payment_received
  def payment_received
    user = User.first || create_sample_user
    NotificationMailer.payment_received(
      user,
      "Payment Received",
      "You received a payment of $150.00 for your appointment with patient@example.com"
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/payment_failed
  def payment_failed
    user = User.first || create_sample_user
    NotificationMailer.payment_failed(
      user,
      "Payment Failed",
      "Your payment of $75.50 could not be processed. Please update your payment method."
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/appointment_booked
  def appointment_booked
    user = User.first || create_sample_user
    NotificationMailer.appointment_booked(
      user,
      "New Appointment Booked",
      "Your appointment has been confirmed for January 15, 2025 at 10:00 AM with Dr. Sarah Johnson for Yoga Therapy session."
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/appointment_cancelled
  def appointment_cancelled
    user = User.first || create_sample_user
    NotificationMailer.appointment_cancelled(
      user,
      "Appointment Cancelled",
      "Your appointment scheduled for January 15, 2025 at 10:00 AM has been cancelled."
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/appointment_reminder
  def appointment_reminder
    user = User.first || create_sample_user
    NotificationMailer.appointment_reminder(
      user,
      "Appointment Reminder",
      "You have an appointment tomorrow at 10:00 AM with Dr. Sarah Johnson for Yoga Therapy session."
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/refund_processed
  def refund_processed
    user = User.first || create_sample_user
    NotificationMailer.refund_processed(
      user,
      "Refund Processed",
      "A refund of $150.00 has been processed for your cancelled appointment."
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/profile_approved
  def profile_approved
    user = User.first || create_sample_user
    NotificationMailer.profile_approved(
      user,
      "Profile Approved",
      "Congratulations! Your provider profile has been approved and is now live on WellnessConnect."
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/new_review
  def new_review
    user = User.first || create_sample_user
    NotificationMailer.new_review(
      user,
      "New Review Received",
      "You have received a new 5-star review from John Doe: 'Excellent service! Highly recommend.'"
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/system_announcement
  def system_announcement
    user = User.first || create_sample_user
    NotificationMailer.system_announcement(
      user,
      "System Maintenance Scheduled",
      "WellnessConnect will undergo scheduled maintenance on Saturday, January 20th from 2:00 AM to 4:00 AM EST. During this time, the platform may be temporarily unavailable."
    )
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/notification
  def notification
    user = User.first || create_sample_user
    NotificationMailer.notification(
      user,
      "Welcome to WellnessConnect",
      "Thank you for joining WellnessConnect! We're excited to have you as part of our wellness community."
    )
  end

  private

  def create_sample_user
    User.new(
      email: "preview@wellnessconnect.com",
      first_name: "John",
      last_name: "Doe",
      role: "provider"
    )
  end
end

