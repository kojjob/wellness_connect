require "test_helper"

class NotificationServiceTest < ActiveSupport::TestCase
  def setup
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @appointment = appointments(:appointment_one)
    @payment = payments(:payment_one)
  end

  # === Preference Integration Tests ===

  test "notify_appointment_booked creates notification for provider when preference enabled" do
    @provider.notification_preference.update!(in_app_appointments: true)

    assert_difference "Notification.count", 2 do # Both provider and patient get notifications
      NotificationService.notify_appointment_booked(@appointment)
    end

    provider_notification = Notification.where(user: @provider, notification_type: "appointment_booked").last
    assert_not_nil provider_notification
    assert_equal "New Appointment Booked", provider_notification.title
  end

  test "notify_appointment_booked does not create notification for provider when preference disabled" do
    @provider.notification_preference.update!(in_app_appointments: false)
    @patient.notification_preference.update!(in_app_appointments: true)

    assert_difference "Notification.count", 1 do # Only patient gets notification
      NotificationService.notify_appointment_booked(@appointment)
    end

    provider_notification = Notification.where(user: @provider, notification_type: "appointment_booked").last
    assert_nil provider_notification
  end

  test "notify_appointment_booked does not create notification for patient when preference disabled" do
    @provider.notification_preference.update!(in_app_appointments: true)
    @patient.notification_preference.update!(in_app_appointments: false)

    assert_difference "Notification.count", 1 do # Only provider gets notification
      NotificationService.notify_appointment_booked(@appointment)
    end

    patient_notification = Notification.where(user: @patient, notification_type: "appointment_booked").last
    assert_nil patient_notification
  end

  test "notify_appointment_booked does not create any notifications when both preferences disabled" do
    @provider.notification_preference.update!(in_app_appointments: false)
    @patient.notification_preference.update!(in_app_appointments: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_appointment_booked(@appointment)
    end
  end

  test "notify_appointment_cancelled respects user preferences" do
    cancelled_by = @patient
    other_user = @provider

    other_user.notification_preference.update!(in_app_appointments: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_appointment_cancelled(@appointment, cancelled_by)
    end

    notification = Notification.where(user: other_user, notification_type: "appointment_cancelled").last
    assert_not_nil notification
  end

  test "notify_appointment_cancelled does not create notification when preference disabled" do
    cancelled_by = @patient
    other_user = @provider

    other_user.notification_preference.update!(in_app_appointments: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_appointment_cancelled(@appointment, cancelled_by)
    end
  end

  test "notify_appointment_reminder creates notifications for both users when preferences enabled" do
    @provider.notification_preference.update!(in_app_appointments: true)
    @patient.notification_preference.update!(in_app_appointments: true)

    assert_difference "Notification.count", 2 do
      NotificationService.notify_appointment_reminder(@appointment)
    end

    patient_notification = Notification.where(user: @patient, notification_type: "appointment_reminder").last
    provider_notification = Notification.where(user: @provider, notification_type: "appointment_reminder").last

    assert_not_nil patient_notification
    assert_not_nil provider_notification
  end

  test "notify_appointment_reminder respects individual user preferences" do
    @provider.notification_preference.update!(in_app_appointments: true)
    @patient.notification_preference.update!(in_app_appointments: false)

    assert_difference "Notification.count", 1 do # Only provider gets notification
      NotificationService.notify_appointment_reminder(@appointment)
    end

    provider_notification = Notification.where(user: @provider, notification_type: "appointment_reminder").last
    assert_not_nil provider_notification
  end

  test "notify_payment_received respects user preferences" do
    @provider.notification_preference.update!(in_app_payments: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_payment_received(@payment)
    end

    notification = Notification.where(user: @provider, notification_type: "payment_received").last
    assert_not_nil notification
    assert_includes notification.message, @payment.amount.to_s
  end

  test "notify_payment_received does not create notification when preference disabled" do
    @provider.notification_preference.update!(in_app_payments: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_payment_received(@payment)
    end
  end

  test "notify_payment_failed respects user preferences" do
    payer = @payment.payer
    payer.notification_preference.update!(in_app_payments: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_payment_failed(@payment)
    end

    notification = Notification.where(user: payer, notification_type: "payment_failed").last
    assert_not_nil notification
  end

  test "notify_payment_failed does not create notification when preference disabled" do
    payer = @payment.payer
    payer.notification_preference.update!(in_app_payments: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_payment_failed(@payment)
    end
  end

  test "notify_profile_approved respects user preferences" do
    provider_profile = provider_profiles(:provider_profile_one)
    user = provider_profile.user
    user.notification_preference.update!(in_app_system: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_profile_approved(provider_profile)
    end

    notification = Notification.where(user: user, notification_type: "profile_approved").last
    assert_not_nil notification
  end

  test "notify_profile_approved does not create notification when preference disabled" do
    provider_profile = provider_profiles(:provider_profile_one)
    user = provider_profile.user
    user.notification_preference.update!(in_app_system: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_profile_approved(provider_profile)
    end
  end

  test "notify_new_review respects user preferences" do
    provider_profile = provider_profiles(:provider_profile_one)
    reviewer = @patient
    user = provider_profile.user
    user.notification_preference.update!(in_app_system: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_new_review(provider_profile, reviewer)
    end

    notification = Notification.where(user: user, notification_type: "new_review").last
    assert_not_nil notification
  end

  test "notify_new_review does not create notification when preference disabled" do
    provider_profile = provider_profiles(:provider_profile_one)
    reviewer = @patient
    user = provider_profile.user
    user.notification_preference.update!(in_app_system: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_new_review(provider_profile, reviewer)
    end
  end

  test "notify_system_announcement respects user preferences" do
    @patient.notification_preference.update!(in_app_system: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_system_announcement(@patient, "Test Title", "Test Message")
    end

    notification = Notification.where(user: @patient, notification_type: "system_announcement").last
    assert_not_nil notification
    assert_equal "Test Title", notification.title
  end

  test "notify_system_announcement does not create notification when preference disabled" do
    @patient.notification_preference.update!(in_app_system: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_system_announcement(@patient, "Test Title", "Test Message")
    end
  end

  test "broadcast_announcement respects individual user preferences" do
    # Enable for patient, disable for provider
    @patient.notification_preference.update!(in_app_system: true)
    @provider.notification_preference.update!(in_app_system: false)

    # Should create notifications for users with preference enabled
    initial_count = Notification.count
    NotificationService.broadcast_announcement("Broadcast Title", "Broadcast Message")

    # Count users with system notifications enabled
    users_with_enabled = User.includes(:notification_preference).select do |user|
      user.notification_preference&.in_app_system
    end.count

    assert_equal initial_count + users_with_enabled, Notification.count
  end

  test "notify_refund_processed respects user preferences" do
    payer = @payment.payer
    payer.notification_preference.update!(in_app_payments: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_refund_processed(@payment, "full", @payment.amount)
    end

    notification = Notification.where(user: payer, notification_type: "refund_processed").last
    assert_not_nil notification
    assert_includes notification.message, "full refund"
  end

  test "notify_refund_processed does not create notification when preference disabled" do
    payer = @payment.payer
    payer.notification_preference.update!(in_app_payments: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_refund_processed(@payment, "full", @payment.amount)
    end
  end

  test "notify_no_refund_policy respects user preferences" do
    payer = @payment.payer
    payer.notification_preference.update!(in_app_payments: true)

    assert_difference "Notification.count", 1 do
      NotificationService.notify_no_refund_policy(@payment)
    end

    notification = Notification.where(user: payer, notification_type: "no_refund").last
    assert_not_nil notification
  end

  test "notify_no_refund_policy does not create notification when preference disabled" do
    payer = @payment.payer
    payer.notification_preference.update!(in_app_payments: false)

    assert_no_difference "Notification.count" do
      NotificationService.notify_no_refund_policy(@payment)
    end
  end

  # === can_notify? Helper Method Tests ===

  test "can_notify? returns true when user has preference enabled" do
    @patient.notification_preference.update!(in_app_appointments: true)
    assert NotificationService.send(:can_notify?, @patient, "appointment_booked")
  end

  test "can_notify? returns false when user has preference disabled" do
    @patient.notification_preference.update!(in_app_appointments: false)
    assert_not NotificationService.send(:can_notify?, @patient, "appointment_booked")
  end

  test "can_notify? creates preferences if they don't exist" do
    new_user = User.create!(
      email: "noprefs@example.com",
      password: "password12345",
      first_name: "No",
      last_name: "Prefs"
    )
    # Remove the auto-created preference to test creation
    new_user.notification_preference.destroy
    new_user.reload

    assert_nil new_user.reload.notification_preference

    # Should create preference and return true
    result = NotificationService.send(:can_notify?, new_user, "appointment_booked")

    assert result
    assert_not_nil new_user.reload.notification_preference
  end

  # === can_email_notify? Helper Method Tests ===

  test "can_email_notify? returns true when user has email preference enabled" do
    @patient.notification_preference.update!(email_appointments: true)
    assert NotificationService.send(:can_email_notify?, @patient, "appointment_booked")
  end

  test "can_email_notify? returns false when user has email preference disabled" do
    @patient.notification_preference.update!(email_appointments: false)
    assert_not NotificationService.send(:can_email_notify?, @patient, "appointment_booked")
  end

  test "can_email_notify? creates preferences if they don't exist" do
    new_user = User.create!(
      email: "noemailprefs@example.com",
      password: "password12345",
      first_name: "No",
      last_name: "EmailPrefs"
    )
    # Remove the auto-created preference to test creation
    new_user.notification_preference.destroy
    new_user.reload

    assert_nil new_user.reload.notification_preference

    # Should create preference and return true
    result = NotificationService.send(:can_email_notify?, new_user, "appointment_booked")

    assert result
    assert_not_nil new_user.reload.notification_preference
  end
end
