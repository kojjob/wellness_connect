require "test_helper"

class NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:patient_user)
    sign_in @user
    @preference = @user.notification_preference || @user.create_notification_preference!
  end

  test "should get edit" do
    get edit_notification_preferences_path
    assert_response :success
    assert_select "h1", text: /Notification Preferences/i
  end

  test "should redirect to sign in when not authenticated" do
    sign_out @user
    get edit_notification_preferences_path
    assert_redirected_to new_user_session_path
  end

  test "should update notification preferences" do
    patch notification_preferences_path, params: {
      notification_preference: {
        email_appointments: false,
        email_messages: true,
        email_payments: false,
        email_system: true,
        in_app_appointments: true,
        in_app_messages: false,
        in_app_payments: true,
        in_app_system: false
      }
    }

    assert_redirected_to edit_notification_preferences_path
    assert_equal "Notification preferences successfully updated.", flash[:notice]

    @preference.reload
    assert_not @preference.email_appointments
    assert @preference.email_messages
    assert_not @preference.email_payments
    assert @preference.email_system
    assert @preference.in_app_appointments
    assert_not @preference.in_app_messages
    assert @preference.in_app_payments
    assert_not @preference.in_app_system
  end

  test "should create preference if user doesn't have one" do
    # Create a new user - the after_create callback will create the preference
    new_user = User.create!(
      email: "newuser@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :patient
    )

    # Verify preference was created by callback
    assert_not_nil new_user.notification_preference

    # Delete it to test the controller's ensure_preference_exists
    new_user.notification_preference.destroy
    assert_nil new_user.reload.notification_preference

    sign_in new_user

    get edit_notification_preferences_path
    assert_response :success
    assert_not_nil new_user.reload.notification_preference
  end

  test "should disable all email notifications" do
    patch notification_preferences_path, params: {
      notification_preference: {
        email_appointments: false,
        email_messages: false,
        email_payments: false,
        email_system: false,
        in_app_appointments: true,
        in_app_messages: true,
        in_app_payments: true,
        in_app_system: true
      }
    }

    @preference.reload
    assert_not @preference.email_notifications_enabled?
  end

  test "should disable all in-app notifications" do
    patch notification_preferences_path, params: {
      notification_preference: {
        email_appointments: true,
        email_messages: true,
        email_payments: true,
        email_system: true,
        in_app_appointments: false,
        in_app_messages: false,
        in_app_payments: false,
        in_app_system: false
      }
    }

    @preference.reload
    assert_not @preference.in_app_notifications_enabled?
  end
end
