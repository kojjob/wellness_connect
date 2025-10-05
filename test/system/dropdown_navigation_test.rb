require "application_system_test_case"

class DropdownNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:patient_user)
    @provider = users(:provider_user)
  end

  test "notification dropdown opens and closes for authenticated user" do
    sign_in @user
    visit root_path
    
    # Verify notification bell is visible
    assert_selector "[data-dropdown-target='button'][aria-label='View notifications']"
    
    # Click notification bell
    find("[data-dropdown-target='button'][aria-label='View notifications']").click
    
    # Verify dropdown menu appears
    assert_selector "[data-dropdown-target='menu']:not(.hidden)", wait: 1
    
    # Verify dropdown has correct ARIA attribute
    assert_selector "[data-dropdown-target='button'][aria-expanded='true']"
    
    # Click outside to close
    find("body").click
    
    # Verify dropdown is hidden
    assert_selector "[data-dropdown-target='menu'].hidden", wait: 1
  end

  test "user profile dropdown opens and closes for authenticated user" do
    sign_in @user
    visit root_path
    
    # Verify user avatar is visible
    assert_selector "[data-dropdown-target='button'][aria-label='User menu']"
    
    # Click user avatar
    find("[data-dropdown-target='button'][aria-label='User menu']").click
    
    # Verify dropdown menu appears
    assert_selector "[data-dropdown-target='menu']:not(.hidden)", wait: 1
    
    # Verify user email is displayed
    assert_text @user.email
    
    # Verify account type is displayed
    assert_text "Patient"
    
    # Click outside to close
    find("body").click
    
    # Verify dropdown is hidden
    assert_selector "[data-dropdown-target='menu'].hidden", wait: 1
  end

  test "provider sees provider account type in profile dropdown" do
    sign_in @provider
    visit root_path
    
    # Click user avatar
    find("[data-dropdown-target='button'][aria-label='User menu']").click
    
    # Verify account type shows Provider
    assert_text "Provider"
  end

  test "notification dropdown shows empty state when no notifications" do
    sign_in @user
    visit root_path
    
    # Click notification bell
    find("[data-dropdown-target='button'][aria-label='View notifications']").click
    
    # Verify empty state message
    assert_text "All caught up!"
    assert_text "You have no new notifications"
  end

  test "notification dropdown shows unread badge when notifications exist" do
    # Create a notification for the user
    notification = Notification.create!(
      user: @user,
      title: "Test Notification",
      message: "This is a test notification",
      notification_type: "system_announcement"
    )
    
    sign_in @user
    visit root_path
    
    # Verify unread badge is visible
    assert_selector ".bg-gradient-to-br.from-red-500.to-pink-500"
    
    # Click notification bell
    find("[data-dropdown-target='button'][aria-label='View notifications']").click
    
    # Verify notification is displayed
    assert_text "Test Notification"
    assert_text "This is a test notification"
  end

  test "user can sign out from profile dropdown" do
    sign_in @user
    visit root_path
    
    # Click user avatar
    find("[data-dropdown-target='button'][aria-label='User menu']").click
    
    # Click sign out button
    click_button "Sign Out"
    
    # Verify user is signed out
    assert_current_path root_path
    assert_text "Sign In"
  end

  test "user can navigate to dashboard from profile dropdown" do
    sign_in @user
    visit root_path
    
    # Click user avatar
    find("[data-dropdown-target='button'][aria-label='User menu']").click
    
    # Click dashboard link
    click_link "My Dashboard"
    
    # Verify navigation to dashboard
    assert_current_path dashboard_path
  end

  test "notification dropdown closes on escape key" do
    sign_in @user
    visit root_path
    
    # Click notification bell
    find("[data-dropdown-target='button'][aria-label='View notifications']").click
    
    # Verify dropdown is open
    assert_selector "[data-dropdown-target='menu']:not(.hidden)"
    
    # Press Escape key
    find("body").send_keys(:escape)
    
    # Verify dropdown is closed
    assert_selector "[data-dropdown-target='menu'].hidden", wait: 1
  end

  test "profile dropdown closes on escape key" do
    sign_in @user
    visit root_path
    
    # Click user avatar
    find("[data-dropdown-target='button'][aria-label='User menu']").click
    
    # Verify dropdown is open
    assert_selector "[data-dropdown-target='menu']:not(.hidden)"
    
    # Press Escape key
    find("body").send_keys(:escape)
    
    # Verify dropdown is closed
    assert_selector "[data-dropdown-target='menu'].hidden", wait: 1
  end

  test "dropdowns are not visible for guest users" do
    visit root_path
    
    # Verify notification bell is not visible
    assert_no_selector "[data-dropdown-target='button'][aria-label='View notifications']"
    
    # Verify user avatar is not visible
    assert_no_selector "[data-dropdown-target='button'][aria-label='User menu']"
    
    # Verify guest buttons are visible
    assert_text "Sign In"
    assert_text "Get Started"
  end

  private

  def sign_in(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end
end
