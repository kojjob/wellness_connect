# Job to send appointment reminders 24 hours before scheduled appointments
# Uses Solid Queue (Rails 8) for background job processing
# Configure recurring schedule in config/recurring.yml or via whenever gem
#
# Can be run in two modes:
# 1. Batch mode (no arguments): Finds all appointments in the 23-25 hour window
# 2. Single mode (appointment_id): Sends reminder for a specific appointment
class AppointmentReminderJob < ApplicationJob
  queue_as :default

  # Retry with exponential backoff if job fails
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(appointment_id = nil)
    if appointment_id.present?
      # Single appointment mode
      send_reminder_for_appointment(appointment_id)
    else
      # Batch mode - find all appointments in reminder window
      send_batch_reminders
    end
  end

  private

  def send_reminder_for_appointment(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)

    # Skip if appointment doesn't exist
    return unless appointment.present?

    # Skip if appointment is cancelled or completed
    return if appointment.status.in?([ "cancelled_by_patient", "cancelled_by_provider", "completed", "no_show" ])

    # Send reminder notifications via NotificationService
    # This respects user preferences and sends both in-app and email notifications
    NotificationService.notify_appointment_reminder(appointment)

    Rails.logger.info "Sent appointment reminder for appointment ##{appointment.id}"
  rescue => e
    Rails.logger.error "Failed to send appointment reminder for appointment ##{appointment_id}: #{e.message}"
    raise # Re-raise to trigger retry logic
  end

  def send_batch_reminders
    # Find appointments that start between 23-25 hours from now
    # (allows for hourly job runs with 1-hour window)
    reminder_window_start = 23.hours.from_now
    reminder_window_end = 25.hours.from_now

    appointments_to_remind = Appointment
      .where(status: :scheduled)
      .where(start_time: reminder_window_start..reminder_window_end)
      .includes(:patient, :provider, :service)

    count = 0
    appointments_to_remind.find_each do |appointment|
      # Send reminder via NotificationService
      # This respects user preferences and sends both in-app and email notifications
      NotificationService.notify_appointment_reminder(appointment)
      count += 1

      Rails.logger.info "Sent reminders for Appointment ##{appointment.id} (#{appointment.service.name} on #{appointment.start_time})"
    rescue => e
      Rails.logger.error "Failed to send reminder for Appointment ##{appointment.id}: #{e.message}"
      # Continue with next appointment
    end

    Rails.logger.info "Appointment reminder job completed. Sent reminders for #{count} appointments."
  end
end
