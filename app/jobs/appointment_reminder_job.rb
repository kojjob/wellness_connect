# Job to send appointment reminders 24 hours before scheduled appointments
# Uses Solid Queue (Rails 8) for background job processing
# Configure recurring schedule in config/recurring.yml or via whenever gem
class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Find appointments that start between 23-25 hours from now
    # (allows for hourly job runs with 1-hour window)
    reminder_window_start = 23.hours.from_now
    reminder_window_end = 25.hours.from_now

    appointments_to_remind = Appointment
      .where(status: :scheduled)
      .where(start_time: reminder_window_start..reminder_window_end)
      .includes(:patient, :provider, :service)

    appointments_to_remind.find_each do |appointment|
      # Send reminder to patient (client)
      AppointmentMailer.reminder_to_patient(appointment).deliver_now

      # Send reminder to provider
      AppointmentMailer.reminder_to_provider(appointment).deliver_now

      Rails.logger.info "Sent reminders for Appointment ##{appointment.id} (#{appointment.service.name} on #{appointment.start_time})"
    end

    Rails.logger.info "Appointment reminder job completed. Sent reminders for #{appointments_to_remind.count} appointments."
  end
end
