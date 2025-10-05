require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @patient = users(:patient_user)
    @provider = users(:provider_user)
  end

  # ========================================
  # Index Action Tests
  # ========================================

  test "admin can access users index" do
    sign_in @admin
    get admin_users_path
    assert_response :success
    assert_select "h1", "User Management"
  end

  test "admin sees all users in index" do
    sign_in @admin
    get admin_users_path
    assert_response :success
    # Should see all users in the system
    User.all.each do |user|
      assert_select "td", text: user.email
    end
  end

  test "admin can search users by name" do
    sign_in @admin
    get admin_users_path, params: { q: @patient.first_name }
    assert_response :success
    assert_select "td", text: @patient.email
  end

  test "admin can search users by email" do
    sign_in @admin
    get admin_users_path, params: { q: @patient.email }
    assert_response :success
    assert_select "td", text: @patient.email
  end

  test "non-admin cannot access users index" do
    sign_in @patient
    get admin_users_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "guest cannot access users index" do
    get admin_users_path
    assert_redirected_to new_user_session_path
  end

  # ========================================
  # Show Action Tests
  # ========================================

  test "admin can view user details" do
    sign_in @admin
    get admin_user_path(@patient)
    assert_response :success
    assert_select "h1", "User Details"
    assert_select "dd", text: @patient.email
  end

  test "admin can view suspended user details" do
    sign_in @admin
    @patient.suspend!("Test suspension")
    get admin_user_path(@patient)
    assert_response :success
    assert_select "dd", text: "suspended"
  end

  test "non-admin cannot view user details" do
    sign_in @patient
    get admin_user_path(@provider)
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # ========================================
  # New Action Tests
  # ========================================

  test "admin can access new user form" do
    sign_in @admin
    get new_admin_user_path
    assert_response :success
    assert_select "h1", "Create New User"
    assert_select "form"
  end

  test "new user form has all required fields" do
    sign_in @admin
    get new_admin_user_path
    assert_response :success
    assert_select "input[name='user[first_name]']"
    assert_select "input[name='user[last_name]']"
    assert_select "input[name='user[email]']"
    assert_select "input[name='user[password]']"
    assert_select "select[name='user[role]']"
  end

  test "non-admin cannot access new user form" do
    sign_in @provider
    get new_admin_user_path
    assert_redirected_to root_path
  end

  # ========================================
  # Create Action Tests
  # ========================================

  test "admin can create new patient user" do
    sign_in @admin
    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          first_name: "New",
          last_name: "Patient",
          email: "newpatient@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "patient"
        }
      }
    end
    assert_redirected_to admin_user_path(User.last)
    assert_equal "User successfully created.", flash[:notice]
  end

  test "admin can create new provider user" do
    sign_in @admin
    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          first_name: "New",
          last_name: "Provider",
          email: "newprovider@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "provider"
        }
      }
    end
    new_user = User.last
    assert_equal "provider", new_user.role
    assert_redirected_to admin_user_path(new_user)
  end

  test "admin can create new admin user" do
    sign_in @admin
    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          first_name: "New",
          last_name: "Admin",
          email: "newadmin@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin"
        }
      }
    end
    new_user = User.last
    assert_equal "admin", new_user.role
  end

  test "create fails with invalid data" do
    sign_in @admin
    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: {
          first_name: "Test",
          last_name: "User",
          email: "", # Invalid: blank email
          password: "password123",
          role: "patient"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "div.error", text: /Email can't be blank/i
  end

  test "non-admin cannot create users" do
    sign_in @patient
    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: {
          first_name: "Test",
          last_name: "User",
          email: "test@example.com",
          password: "password123",
          role: "patient"
        }
      }
    end
    assert_redirected_to root_path
  end

  # ========================================
  # Edit Action Tests
  # ========================================

  test "admin can access edit user form" do
    sign_in @admin
    get edit_admin_user_path(@patient)
    assert_response :success
    assert_select "h1", "Edit User"
    assert_select "form"
  end

  test "edit form is pre-filled with user data" do
    sign_in @admin
    get edit_admin_user_path(@patient)
    assert_response :success
    assert_select "input[name='user[first_name]'][value=?]", @patient.first_name
    assert_select "input[name='user[email]'][value=?]", @patient.email
  end

  test "non-admin cannot access edit user form" do
    sign_in @patient
    get edit_admin_user_path(@provider)
    assert_redirected_to root_path
  end

  # ========================================
  # Update Action Tests
  # ========================================

  test "admin can update user details" do
    sign_in @admin
    patch admin_user_path(@patient), params: {
      user: {
        first_name: "Updated",
        last_name: "Name"
      }
    }
    @patient.reload
    assert_equal "Updated", @patient.first_name
    assert_equal "Name", @patient.last_name
    assert_redirected_to admin_user_path(@patient)
    assert_equal "User successfully updated.", flash[:notice]
  end

  test "admin can change user role" do
    sign_in @admin
    assert_equal "patient", @patient.role
    patch admin_user_path(@patient), params: {
      user: { role: "provider" }
    }
    @patient.reload
    assert_equal "provider", @patient.role
  end

  test "update fails with invalid data" do
    sign_in @admin
    patch admin_user_path(@patient), params: {
      user: { email: "" }
    }
    assert_response :unprocessable_entity
    @patient.reload
    assert_not_equal "", @patient.email
  end

  test "non-admin cannot update users" do
    sign_in @patient
    original_name = @provider.first_name
    patch admin_user_path(@provider), params: {
      user: { first_name: "Hacked" }
    }
    assert_redirected_to root_path
    @provider.reload
    assert_equal original_name, @provider.first_name
  end

  # ========================================
  # Destroy Action Tests
  # ========================================

  test "admin can delete user" do
    sign_in @admin
    user_to_delete = User.create!(
      first_name: "To Delete",
      last_name: "User",
      email: "todelete@example.com",
      password: "password123",
      role: "patient"
    )

    assert_difference("User.count", -1) do
      delete admin_user_path(user_to_delete)
    end
    assert_redirected_to admin_users_path
    assert_equal "User successfully deleted.", flash[:notice]
  end

  test "non-admin cannot delete users" do
    sign_in @patient
    assert_no_difference("User.count") do
      delete admin_user_path(@provider)
    end
    assert_redirected_to root_path
  end

  # ========================================
  # Suspend Action Tests
  # ========================================

  test "admin can suspend user" do
    sign_in @admin
    assert_nil @patient.suspended_at
    post suspend_admin_user_path(@patient), params: {
      reason: "Policy violation"
    }
    @patient.reload
    assert_not_nil @patient.suspended_at
    assert_equal "Policy violation", @patient.status_reason
    assert_redirected_to admin_user_path(@patient)
    assert_equal "User successfully suspended.", flash[:notice]
  end

  test "admin can suspend user without reason" do
    sign_in @admin
    post suspend_admin_user_path(@patient)
    @patient.reload
    assert_not_nil @patient.suspended_at
    assert_nil @patient.status_reason
  end

  test "non-admin cannot suspend users" do
    sign_in @provider
    post suspend_admin_user_path(@patient), params: {
      reason: "Test"
    }
    assert_redirected_to root_path
    @patient.reload
    assert_nil @patient.suspended_at
  end

  # ========================================
  # Unsuspend Action Tests
  # ========================================

  test "admin can unsuspend user" do
    sign_in @admin
    @patient.suspend!("Test suspension")
    assert_not_nil @patient.suspended_at

    post unsuspend_admin_user_path(@patient)
    @patient.reload
    assert_nil @patient.suspended_at
    assert_nil @patient.status_reason
    assert_redirected_to admin_user_path(@patient)
    assert_equal "User successfully unsuspended.", flash[:notice]
  end

  test "non-admin cannot unsuspend users" do
    sign_in @provider
    @patient.suspend!("Test")
    post unsuspend_admin_user_path(@patient)
    assert_redirected_to root_path
    @patient.reload
    assert_not_nil @patient.suspended_at
  end

  # ========================================
  # Block Action Tests
  # ========================================

  test "admin can block user" do
    sign_in @admin
    assert_nil @patient.blocked_at
    post block_admin_user_path(@patient), params: {
      reason: "Fraudulent activity"
    }
    @patient.reload
    assert_not_nil @patient.blocked_at
    assert_equal "Fraudulent activity", @patient.status_reason
    assert_redirected_to admin_user_path(@patient)
    assert_equal "User successfully blocked.", flash[:notice]
  end

  test "admin can block user without reason" do
    sign_in @admin
    post block_admin_user_path(@patient)
    @patient.reload
    assert_not_nil @patient.blocked_at
    assert_nil @patient.status_reason
  end

  test "non-admin cannot block users" do
    sign_in @provider
    post block_admin_user_path(@patient), params: {
      reason: "Test"
    }
    assert_redirected_to root_path
    @patient.reload
    assert_nil @patient.blocked_at
  end

  # ========================================
  # Unblock Action Tests
  # ========================================

  test "admin can unblock user" do
    sign_in @admin
    @patient.block!("Test block")
    assert_not_nil @patient.blocked_at

    post unblock_admin_user_path(@patient)
    @patient.reload
    assert_nil @patient.blocked_at
    assert_nil @patient.status_reason
    assert_redirected_to admin_user_path(@patient)
    assert_equal "User successfully unblocked.", flash[:notice]
  end

  test "non-admin cannot unblock users" do
    sign_in @provider
    @patient.block!("Test")
    post unblock_admin_user_path(@patient)
    assert_redirected_to root_path
    @patient.reload
    assert_not_nil @patient.blocked_at
  end
end
