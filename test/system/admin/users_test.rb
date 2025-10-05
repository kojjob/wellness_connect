require "application_system_test_case"

module Admin
  class UsersTest < ApplicationSystemTestCase
    def setup
      @admin = users(:admin_user)
      @patient = users(:patient_user)
      @provider = users(:provider_user)
    end

    # Helper methods
    def sign_in_as(user)
      visit new_user_session_path

      within "form" do
        fill_in "Email", with: user.email
        fill_in "Password", with: "password123"
        click_button "Sign In"
      end

      # Wait for redirect after sign in
      assert_current_path root_path
    end

    def sign_out
      click_button "Account"
      click_link "Sign out"
    end

    # Authorization tests
    test "non-admin cannot access admin users index" do
      sign_in_as(@patient)
      visit admin_users_path

      assert_text "You are not authorized to perform this action."
      assert_current_path root_path
    end

    test "guest cannot access admin users index" do
      visit admin_users_path

      # Should redirect to sign in
      assert_current_path new_user_session_path
    end

    # Index page tests
    test "admin can view users index" do
      sign_in_as(@admin)

      visit admin_users_path
      assert_text "User Management"
      assert_selector "table"
      assert_text @admin.full_name
      assert_text @patient.full_name
      assert_text @provider.full_name
    end

    test "admin can search users by name" do
      sign_in_as(@admin)

      visit admin_users_path
      fill_in "q", with: @patient.first_name
      click_button "Search"

      assert_text @patient.full_name
      assert_no_text @provider.full_name
    end

    test "admin can search users by email" do
      sign_in_as(@admin)

      visit admin_users_path
      fill_in "q", with: @provider.email
      click_button "Search"

      assert_text @provider.full_name
      assert_no_text @patient.full_name
    end

    # Create user tests
    test "admin can create new patient user" do
      sign_in_as(@admin)

      visit admin_users_path
      click_link "Create New User"

      assert_text "Create New User"
      within "form" do
        fill_in "user_first_name", with: "New"
        fill_in "user_last_name", with: "Patient"
        fill_in "user_email", with: "newpatient@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"
        select "Patient", from: "user_role"
        click_button "Create User"
      end

      assert_text "User successfully created."
      assert_text "New Patient"
      assert_text "newpatient@example.com"
    end

    test "admin can create new provider user" do
      sign_in_as(@admin)

      visit new_admin_user_path
      within "form" do
        fill_in "user_first_name", with: "New"
        fill_in "user_last_name", with: "Provider"
        fill_in "user_email", with: "newprovider@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"
        select "Provider", from: "user_role"
        click_button "Create User"
      end

      assert_text "User successfully created."
      assert_text "New Provider"
    end

    test "admin cannot create user with invalid data" do
      sign_in_as(@admin)

      visit new_admin_user_path
      fill_in "user_email", with: "invalid"
      # Leave password blank - Devise requires password
      click_button "Create User"

      # Check for Devise validation errors
      assert_text "Email is invalid"
      assert_text "Password can't be blank"
      assert_selector "div.error"
    end

    # Edit user tests
    test "admin can edit user details" do
      sign_in_as(@admin)

      visit admin_user_path(@patient)
      click_link "Edit User"

      assert_text "Edit User"
      within "form" do
        fill_in "user_first_name", with: "Updated"
        fill_in "user_last_name", with: "Name"
        click_button "Update User"
      end

      assert_text "User successfully updated."
      assert_text "Updated Name"
    end

    test "admin can change user role" do
      sign_in_as(@admin)

      visit edit_admin_user_path(@patient)
      within "form" do
        select "Provider", from: "user_role"
        click_button "Update User"
      end

      assert_text "User successfully updated."

      visit admin_user_path(@patient)
      assert_text "Provider"
    end

    # Delete user tests
    test "admin can delete user" do
      sign_in_as(@admin)

      visit admin_user_path(@patient)

      # Handle Turbo confirmation by dismissing it via JavaScript
      page.driver.browser.execute_script("window.confirm = function() { return true; }")
      click_button "Delete User"

      assert_text "User successfully deleted."
      assert_current_path admin_users_path
      assert_no_text @patient.email
    end

    # Suspend user tests
    test "admin can suspend active user" do
      sign_in_as(@admin)

      visit admin_user_path(@patient)
      assert_button "Suspend User"

      click_button "Suspend User"

      assert_text "User successfully suspended."
      assert_text "suspended"
      assert_button "Unsuspend User"
      assert_no_button "Suspend User"
    end

    test "admin can unsuspend suspended user" do
      @patient.suspend!("Test suspension")

      sign_in_as(@admin)

      visit admin_user_path(@patient)
      assert_button "Unsuspend User"

      click_button "Unsuspend User"

      assert_text "User successfully unsuspended."
      assert_text "active"
      assert_button "Suspend User"
      assert_no_button "Unsuspend User"
    end

    # Block user tests
    test "admin can block active user" do
      sign_in_as(@admin)

      visit admin_user_path(@patient)
      assert_button "Block User"

      click_button "Block User"

      assert_text "User successfully blocked."
      assert_text "blocked"
      assert_button "Unblock User"
      assert_no_button "Block User"
    end

    test "admin can unblock blocked user" do
      @patient.block!("Test blocking")

      sign_in_as(@admin)

      visit admin_user_path(@patient)
      assert_button "Unblock User"

      click_button "Unblock User"

      assert_text "User successfully unblocked."
      assert_text "active"
      assert_button "Block User"
      assert_no_button "Unblock User"
    end

    # User status workflow tests
    test "suspended user cannot sign in" do
      @patient.suspend!("Account suspended")

      visit new_user_session_path
      fill_in "Email", with: @patient.email
      fill_in "Password", with: "password123"
      click_button "Sign In"

      assert_text "Your account has been suspended"
    end

    test "blocked user cannot sign in" do
      @patient.block!("Account blocked")

      visit new_user_session_path
      fill_in "Email", with: @patient.email
      fill_in "Password", with: "password123"
      click_button "Sign In"

      assert_text "Your account has been blocked"
    end

    # Complete workflow test
    test "admin user management complete workflow" do
      sign_in_as(@admin)

      # 1. View all users
      visit admin_users_path
      assert_text "User Management"
      assert_selector "table"

      # 2. Create new user
      click_link "Create New User"
      within "form" do
        fill_in "user_first_name", with: "Test"
        fill_in "user_last_name", with: "User"
        fill_in "user_email", with: "testuser@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"
        select "Patient", from: "user_role"
        click_button "Create User"
      end
      assert_text "User successfully created."

      # 3. View user details
      new_user = User.find_by(email: "testuser@example.com")
      visit admin_user_path(new_user)
      assert_text "Test User"
      assert_text "testuser@example.com"

      # 4. Edit user
      click_link "Edit User"
      within "form" do
        fill_in "user_first_name", with: "Modified"
        click_button "Update User"
      end
      assert_text "Modified User"

      # 5. Suspend user
      click_button "Suspend User"
      assert_text "User successfully suspended."
      assert_text "suspended"

      # 6. Unsuspend user
      click_button "Unsuspend User"
      assert_text "User successfully unsuspended."
      assert_text "active"

      # 7. Block user
      click_button "Block User"
      assert_text "User successfully blocked."
      assert_text "blocked"

      # 8. Unblock user
      click_button "Unblock User"
      assert_text "User successfully unblocked."
      assert_text "active"

      # 9. Delete user
      page.driver.browser.execute_script("window.confirm = function() { return true; }")
      click_button "Delete User"
      assert_text "User successfully deleted."
      assert_current_path admin_users_path
    end
  end
end
