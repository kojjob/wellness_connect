# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer
class AppointmentMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/appointment_mailer/booking_confirmation
  def booking_confirmation
    AppointmentMailer.booking_confirmation
  end

  # Preview this email at http://localhost:3000/rails/mailers/appointment_mailer/provider_booking_notification
  def provider_booking_notification
    AppointmentMailer.provider_booking_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/appointment_mailer/cancellation_notification
  def cancellation_notification
    AppointmentMailer.cancellation_notification
  end
end
