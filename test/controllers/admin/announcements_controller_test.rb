require "test_helper"

class Admin::AnnouncementsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin_user)
    @super_admin = users(:super_admin_user)
    @patient = users(:patient_user)
  end

  # === Authorization Tests ===
  test "should redirect to root if not logged in" do
    get new_admin_announcement_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect to root if not admin" do
    sign_in @patient
    get new_admin_announcement_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "admin can access new announcement page" do
    sign_in @admin
    get new_admin_announcement_path
    assert_response :success
  end

  test "super_admin can access new announcement page" do
    sign_in @super_admin
    get new_admin_announcement_path
    assert_response :success
  end

  # === New Action Tests ===
  test "new should display announcement form" do
    sign_in @admin
    get new_admin_announcement_path
    assert_response :success
    assert_select "form"
    assert_select "input[name='announcement[title]']"
    assert_select "textarea[name='announcement[message]']"
  end

  # === Create Action Tests ===
  test "should create announcement for all users" do
    sign_in @admin

    # Count users who will actually receive the notification
    expected_count = User.count { |u| u.notification_preference&.in_app_system != false }

    assert_difference("Notification.count", expected_count) do
      post admin_announcements_path, params: {
        announcement: {
          title: "System Maintenance",
          message: "We will be performing maintenance on Sunday.",
          recipient_type: "all"
        }
      }
    end

    assert_redirected_to admin_root_path
    assert_match(/Announcement sent to \d+ users successfully/, flash[:notice])
  end

  test "should create announcement for patients only" do
    sign_in @admin
    patient_count = User.where(role: "patient").count
    
    assert_difference("Notification.count", patient_count) do
      post admin_announcements_path, params: {
        announcement: {
          title: "Patient Update",
          message: "New features for patients.",
          recipient_type: "patients"
        }
      }
    end

    assert_redirected_to admin_root_path
    assert_match(/sent to \d+ patients/, flash[:notice])
  end

  test "should create announcement for providers only" do
    sign_in @admin
    provider_count = User.where(role: "provider").count
    
    assert_difference("Notification.count", provider_count) do
      post admin_announcements_path, params: {
        announcement: {
          title: "Provider Update",
          message: "New features for providers.",
          recipient_type: "providers"
        }
      }
    end

    assert_redirected_to admin_root_path
    assert_match(/sent to \d+ providers/, flash[:notice])
  end

  test "should create announcement for specific user" do
    sign_in @admin
    
    assert_difference("Notification.count", 1) do
      post admin_announcements_path, params: {
        announcement: {
          title: "Personal Message",
          message: "This is for you.",
          recipient_type: "specific",
          user_id: @patient.id
        }
      }
    end

    assert_redirected_to admin_root_path
    assert_equal "Announcement sent to #{@patient.email} successfully.", flash[:notice]
  end

  test "should not create announcement with invalid params" do
    sign_in @admin
    
    assert_no_difference("Notification.count") do
      post admin_announcements_path, params: {
        announcement: {
          title: "",
          message: "",
          recipient_type: "all"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error", text: /can't be blank/
  end

  test "should require user_id when recipient_type is specific" do
    sign_in @admin
    
    assert_no_difference("Notification.count") do
      post admin_announcements_path, params: {
        announcement: {
          title: "Test",
          message: "Test message",
          recipient_type: "specific",
          user_id: nil
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # === Preview Action Tests ===
  # Preview functionality can be added later as an enhancement

  # === Notification Preference Respect Tests ===
  test "should respect user notification preferences" do
    sign_in @admin
    
    # Disable system notifications for patient
    @patient.notification_preference.update!(in_app_system: false)
    
    # Should not create notification for patient with disabled preferences
    initial_count = Notification.where(user: @patient).count
    
    post admin_announcements_path, params: {
      announcement: {
        title: "System Update",
        message: "New system features.",
        recipient_type: "all"
      }
    }
    
    # Patient should not receive notification
    assert_equal initial_count, Notification.where(user: @patient).count
  end

  test "should count only users who will receive notification" do
    sign_in @admin
    
    # Disable system notifications for some users
    User.limit(2).each do |user|
      user.notification_preference.update!(in_app_system: false)
    end
    
    post admin_announcements_path, params: {
      announcement: {
        title: "Test",
        message: "Test message",
        recipient_type: "all"
      }
    }
    
    # Should mention actual count in flash message
    assert_match(/sent to \d+ users/, flash[:notice])
  end
end
