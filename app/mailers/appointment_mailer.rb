class AppointmentMailer < ApplicationMailer
  default from: "noreply@wellnessconnect.com"

  # Send appointment reminder to patient (client) 24 hours before
  def reminder_to_patient(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @service = appointment.service
    @appointment_time = appointment.start_time.in_time_zone(@patient.time_zone || 'UTC')

    mail(
      to: @patient.email,
      subject: "Reminder: Your #{@service.name} session is tomorrow"
    )
  end

  # Send appointment reminder to provider 24 hours before
  def reminder_to_provider(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @service = appointment.service
    @appointment_time = appointment.start_time.in_time_zone(@provider.time_zone || 'UTC')

    mail(
      to: @provider.email,
      subject: "Reminder: Session with #{@patient.full_name} tomorrow"
    )
  end

  # Send booking confirmation to patient
  def booking_confirmation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @service = appointment.service

    mail(
      to: @patient.email,
      subject: "Appointment Confirmed - #{@service.name}"
    )
  end

  # Send booking notification to provider
  def provider_booking_notification(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @service = appointment.service

    mail(
      to: @provider.email,
      subject: "New Booking: #{@patient.full_name}"
    )
  end

  # Send cancellation notification to either patient or provider
  def cancellation_notification(appointment, recipient)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @service = appointment.service
    @recipient = recipient
    @is_patient = (recipient == @patient)

    subject = if @is_patient
      "Appointment Cancelled - #{@service.name}"
    else
      "Appointment Cancelled - #{@patient.full_name}"
    end

    mail(
      to: recipient.email,
      subject: subject
    )
  end
end
