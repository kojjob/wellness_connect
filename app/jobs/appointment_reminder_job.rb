# frozen_string_literal: true

# Job to send appointment reminders 24 hours before scheduled appointments
# Runs hourly via Solid Queue recurring jobs (configured in config/recurring.yml)
class AppointmentReminderJob < ApplicationJob
  queue_as :default

  # Find appointments scheduled 23-25 hours from now and send reminders
  # Uses a 1-hour window to account for job execution timing
  def perform
    reminder_window_start = 23.hours.from_now
    reminder_window_end = 25.hours.from_now

    appointments_needing_reminder = Appointment
      .where(status: :scheduled)
      .where(start_time: reminder_window_start..reminder_window_end)
      .includes(:patient, :provider, service: :provider_profile)

    reminder_count = 0

    appointments_needing_reminder.find_each do |appointment|
      # Use NotificationService to send both in-app notification and email
      NotificationService.notify_appointment_reminder(appointment)
      reminder_count += 1
    end

    Rails.logger.info "AppointmentReminderJob completed: Sent reminders for #{reminder_count} appointments"

    reminder_count
  end
end
