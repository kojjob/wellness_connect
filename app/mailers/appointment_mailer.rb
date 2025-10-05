class AppointmentMailer < ApplicationMailer
  # Booking confirmation email sent to patient after payment succeeds
  def booking_confirmation_to_patient(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @provider_profile = appointment.service.provider_profile
    @service = appointment.service

    mail(
      to: @patient.email,
      subject: "Booking Confirmed: #{@service.name} with #{@provider_profile.full_name}"
    )
  end

  # Booking confirmation email sent to provider after payment succeeds
  def booking_confirmation_to_provider(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @provider_profile = appointment.service.provider_profile
    @service = appointment.service

    mail(
      to: @provider.email,
      subject: "New Booking: #{@service.name} with #{@patient.full_name}"
    )
  end

  # Cancellation notification sent to patient
  def cancellation_to_patient(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @provider_profile = appointment.service.provider_profile
    @service = appointment.service
    @cancelled_by_provider = appointment.cancelled_by_provider?

    mail(
      to: @patient.email,
      subject: "Appointment Cancelled: #{@service.name}"
    )
  end

  # Cancellation notification sent to provider
  def cancellation_to_provider(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @provider_profile = appointment.service.provider_profile
    @service = appointment.service
    @cancelled_by_patient = appointment.cancelled_by_patient?

    mail(
      to: @provider.email,
      subject: "Appointment Cancelled: #{@service.name} with #{@patient.full_name}"
    )
  end

  # Reminder sent to patient 24 hours before appointment
  def reminder_to_patient(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @provider_profile = appointment.service.provider_profile
    @service = appointment.service

    mail(
      to: @patient.email,
      subject: "Reminder: Your appointment with #{@provider_profile.full_name} is tomorrow"
    )
  end

  # Reminder sent to provider 24 hours before appointment
  def reminder_to_provider(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @provider_profile = appointment.service.provider_profile
    @service = appointment.service

    mail(
      to: @provider.email,
      subject: "Reminder: Appointment with #{@patient.full_name} is tomorrow"
    )
  end
end
