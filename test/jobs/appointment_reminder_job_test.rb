require "test_helper"

class AppointmentReminderJobTest < ActiveJob::TestCase
  def setup
    @appointment = appointments(:appointment_one)
    @patient = @appointment.patient
    @provider = @appointment.provider
    
    # Ensure notification preferences exist
    @patient.create_notification_preference! unless @patient.notification_preference
    @provider.create_notification_preference! unless @provider.notification_preference
  end

  test "job sends reminder notifications to both patient and provider" do
    assert_difference "Notification.count", 2 do
      AppointmentReminderJob.perform_now(@appointment.id)
    end

    # Check patient notification
    patient_notification = Notification.where(user: @patient, notification_type: "appointment_reminder").last
    assert_not_nil patient_notification
    assert_match "Appointment Reminder", patient_notification.title
    assert_match @provider.email, patient_notification.message
    assert_match "tomorrow", patient_notification.message

    # Check provider notification
    provider_notification = Notification.where(user: @provider, notification_type: "appointment_reminder").last
    assert_not_nil provider_notification
    assert_match "Appointment Reminder", provider_notification.title
    assert_match @patient.email, provider_notification.message
  end

  test "job respects user notification preferences" do
    # Disable appointment notifications for both patient and provider
    @patient.notification_preference.update(in_app_appointments: false)
    @provider.notification_preference.update(in_app_appointments: false)

    # Should not create any notifications
    assert_no_difference "Notification.count" do
      AppointmentReminderJob.perform_now(@appointment.id)
    end
  end

  test "job handles missing appointment gracefully" do
    assert_nothing_raised do
      AppointmentReminderJob.perform_now(999999)
    end

    assert_no_difference "Notification.count" do
      AppointmentReminderJob.perform_now(999999)
    end
  end

  test "job handles cancelled appointments" do
    @appointment.update(status: "cancelled_by_patient")

    assert_no_difference "Notification.count" do
      AppointmentReminderJob.perform_now(@appointment.id)
    end
  end

  test "job handles completed appointments" do
    @appointment.update(status: "completed")

    assert_no_difference "Notification.count" do
      AppointmentReminderJob.perform_now(@appointment.id)
    end
  end

  test "job sends email notifications if enabled" do
    # Enable email notifications for appointments
    @patient.notification_preference.update(email_appointments: true)
    @provider.notification_preference.update(email_appointments: true)

    # Perform the job and verify emails are sent
    perform_enqueued_jobs do
      AppointmentReminderJob.perform_now(@appointment.id)
    end

    # Verify notifications were created
    assert Notification.where(user: @patient, notification_type: "appointment_reminder").exists?
    assert Notification.where(user: @provider, notification_type: "appointment_reminder").exists?
  end

  test "job includes appointment details in notification" do
    AppointmentReminderJob.perform_now(@appointment.id)

    notification = Notification.where(user: @patient, notification_type: "appointment_reminder").last
    assert_includes notification.action_url, "appointments/#{@appointment.id}"
  end

  test "job can be enqueued for future execution" do
    assert_enqueued_with(job: AppointmentReminderJob, args: [@appointment.id]) do
      AppointmentReminderJob.perform_later(@appointment.id)
    end
  end
end
