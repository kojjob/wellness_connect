require "test_helper"

class NotificationPreferenceTest < ActiveSupport::TestCase
  def setup
    @user = users(:patient_user)
    @preference = notification_preferences(:patient_user_preference)
  end

  # === Association Tests ===
  test "belongs to user" do
    assert_respond_to @preference, :user
    assert_equal @user, @preference.user
  end

  # === Validation Tests ===
  test "requires user_id" do
    preference = NotificationPreference.new
    assert_not preference.valid?
    assert_includes preference.errors[:user_id], "can't be blank"
  end

  test "enforces uniqueness of user_id" do
    duplicate = NotificationPreference.new(user: @user)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  # === Default Values Tests ===
  test "defaults all email preferences to true" do
    new_user = User.create!(
      email: "test@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    )
    preference = new_user.notification_preference

    assert preference.email_appointments
    assert preference.email_messages
    assert preference.email_payments
    assert preference.email_system
  end

  test "defaults all in_app preferences to true" do
    new_user = User.create!(
      email: "test2@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    )
    preference = new_user.notification_preference

    assert preference.in_app_appointments
    assert preference.in_app_messages
    assert preference.in_app_payments
    assert preference.in_app_system
  end

  # === email_enabled_for? Tests ===
  test "email_enabled_for? returns true for appointment notifications when enabled" do
    @preference.update!(email_appointments: true)
    assert @preference.email_enabled_for?("appointment_booked")
    assert @preference.email_enabled_for?("appointment_cancelled")
    assert @preference.email_enabled_for?("appointment_reminder")
  end

  test "email_enabled_for? returns false for appointment notifications when disabled" do
    @preference.update!(email_appointments: false)
    assert_not @preference.email_enabled_for?("appointment_booked")
    assert_not @preference.email_enabled_for?("appointment_cancelled")
  end

  test "email_enabled_for? returns true for message notifications when enabled" do
    @preference.update!(email_messages: true)
    assert @preference.email_enabled_for?("new_message")
    assert @preference.email_enabled_for?("message_received")
  end

  test "email_enabled_for? returns false for message notifications when disabled" do
    @preference.update!(email_messages: false)
    assert_not @preference.email_enabled_for?("new_message")
  end

  test "email_enabled_for? returns true for payment notifications when enabled" do
    @preference.update!(email_payments: true)
    assert @preference.email_enabled_for?("payment_received")
    assert @preference.email_enabled_for?("payment_failed")
    assert @preference.email_enabled_for?("refund_processed")
  end

  test "email_enabled_for? returns false for payment notifications when disabled" do
    @preference.update!(email_payments: false)
    assert_not @preference.email_enabled_for?("payment_received")
    assert_not @preference.email_enabled_for?("refund_processed")
  end

  test "email_enabled_for? returns true for system notifications when enabled" do
    @preference.update!(email_system: true)
    assert @preference.email_enabled_for?("system_announcement")
    assert @preference.email_enabled_for?("profile_approved")
  end

  test "email_enabled_for? returns false for system notifications when disabled" do
    @preference.update!(email_system: false)
    assert_not @preference.email_enabled_for?("system_announcement")
  end

  test "email_enabled_for? defaults to true for unknown notification types" do
    assert @preference.email_enabled_for?("unknown_type")
    assert @preference.email_enabled_for?("custom_notification")
  end

  # === in_app_enabled_for? Tests ===
  test "in_app_enabled_for? returns true for appointment notifications when enabled" do
    @preference.update!(in_app_appointments: true)
    assert @preference.in_app_enabled_for?("appointment_booked")
    assert @preference.in_app_enabled_for?("appointment_cancelled")
    assert @preference.in_app_enabled_for?("appointment_reminder")
  end

  test "in_app_enabled_for? returns false for appointment notifications when disabled" do
    @preference.update!(in_app_appointments: false)
    assert_not @preference.in_app_enabled_for?("appointment_booked")
  end

  test "in_app_enabled_for? returns true for message notifications when enabled" do
    @preference.update!(in_app_messages: true)
    assert @preference.in_app_enabled_for?("new_message")
  end

  test "in_app_enabled_for? returns false for message notifications when disabled" do
    @preference.update!(in_app_messages: false)
    assert_not @preference.in_app_enabled_for?("new_message")
  end

  test "in_app_enabled_for? returns true for payment notifications when enabled" do
    @preference.update!(in_app_payments: true)
    assert @preference.in_app_enabled_for?("payment_received")
    assert @preference.in_app_enabled_for?("refund_processed")
  end

  test "in_app_enabled_for? returns false for payment notifications when disabled" do
    @preference.update!(in_app_payments: false)
    assert_not @preference.in_app_enabled_for?("payment_received")
  end

  test "in_app_enabled_for? returns true for system notifications when enabled" do
    @preference.update!(in_app_system: true)
    assert @preference.in_app_enabled_for?("system_announcement")
  end

  test "in_app_enabled_for? returns false for system notifications when disabled" do
    @preference.update!(in_app_system: false)
    assert_not @preference.in_app_enabled_for?("system_announcement")
  end

  test "in_app_enabled_for? defaults to true for unknown notification types" do
    assert @preference.in_app_enabled_for?("unknown_type")
  end

  # === Status Check Methods Tests ===
  test "email_notifications_enabled? returns true when at least one email preference is enabled" do
    @preference.update!(
      email_appointments: false,
      email_messages: true,
      email_payments: false,
      email_system: false
    )
    assert @preference.email_notifications_enabled?
  end

  test "email_notifications_enabled? returns false when all email preferences are disabled" do
    @preference.update!(
      email_appointments: false,
      email_messages: false,
      email_payments: false,
      email_system: false
    )
    assert_not @preference.email_notifications_enabled?
  end

  test "in_app_notifications_enabled? returns true when at least one in_app preference is enabled" do
    @preference.update!(
      in_app_appointments: false,
      in_app_messages: false,
      in_app_payments: true,
      in_app_system: false
    )
    assert @preference.in_app_notifications_enabled?
  end

  test "in_app_notifications_enabled? returns false when all in_app preferences are disabled" do
    @preference.update!(
      in_app_appointments: false,
      in_app_messages: false,
      in_app_payments: false,
      in_app_system: false
    )
    assert_not @preference.in_app_notifications_enabled?
  end

  # === Bulk Update Methods Tests ===
  test "disable_all_email! sets all email preferences to false" do
    @preference.update!(
      email_appointments: true,
      email_messages: true,
      email_payments: true,
      email_system: true
    )

    @preference.disable_all_email!
    @preference.reload

    assert_not @preference.email_appointments
    assert_not @preference.email_messages
    assert_not @preference.email_payments
    assert_not @preference.email_system
  end

  test "enable_all_email! sets all email preferences to true" do
    @preference.update!(
      email_appointments: false,
      email_messages: false,
      email_payments: false,
      email_system: false
    )

    @preference.enable_all_email!
    @preference.reload

    assert @preference.email_appointments
    assert @preference.email_messages
    assert @preference.email_payments
    assert @preference.email_system
  end

  test "disable_all_in_app! sets all in_app preferences to false" do
    @preference.update!(
      in_app_appointments: true,
      in_app_messages: true,
      in_app_payments: true,
      in_app_system: true
    )

    @preference.disable_all_in_app!
    @preference.reload

    assert_not @preference.in_app_appointments
    assert_not @preference.in_app_messages
    assert_not @preference.in_app_payments
    assert_not @preference.in_app_system
  end

  test "enable_all_in_app! sets all in_app preferences to true" do
    @preference.update!(
      in_app_appointments: false,
      in_app_messages: false,
      in_app_payments: false,
      in_app_system: false
    )

    @preference.enable_all_in_app!
    @preference.reload

    assert @preference.in_app_appointments
    assert @preference.in_app_messages
    assert @preference.in_app_payments
    assert @preference.in_app_system
  end

  # === Integration Tests ===
  test "user automatically gets notification preferences after creation" do
    new_user = User.create!(
      email: "autopreference@example.com",
      password: "password123",
      first_name: "Auto",
      last_name: "Preference"
    )

    assert_not_nil new_user.notification_preference
    assert new_user.notification_preference.persisted?
  end

  test "destroying user also destroys notification preferences" do
    new_user = User.create!(
      email: "destroy@example.com",
      password: "password123",
      first_name: "Destroy",
      last_name: "Test"
    )
    preference_id = new_user.notification_preference.id

    new_user.destroy
    assert_nil NotificationPreference.find_by(id: preference_id)
  end
end
