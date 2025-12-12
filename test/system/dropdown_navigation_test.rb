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

    notification_button = find("[data-dropdown-target='button'][aria-label='View notifications']")
    notification_dropdown = notification_button.find(:xpath, "./ancestor::div[@data-controller='dropdown'][1]")

    # Click notification bell
    notification_button.click

    # Verify dropdown menu appears
    within notification_dropdown do
      assert_selector "[data-dropdown-target='menu']:not(.hidden)", wait: 2
    end

    # Verify dropdown has correct ARIA attribute
    assert_selector "[data-dropdown-target='button'][aria-expanded='true']"

    # Click outside to close
    find("body").click

    # Verify dropdown is hidden
    within notification_dropdown do
      assert_selector "[data-dropdown-target='menu'].hidden", visible: :all, wait: 3
    end
  end

  test "user profile dropdown opens and closes for authenticated user" do
    sign_in @user
    visit root_path

    # Verify user avatar is visible
    assert_selector "[data-dropdown-target='button'][aria-label='User menu']"

    user_button = find("[data-dropdown-target='button'][aria-label='User menu']")
    user_dropdown = user_button.find(:xpath, "./ancestor::div[@data-controller='dropdown'][1]")

    # Click user avatar
    user_button.click

    # Verify dropdown menu appears
    within user_dropdown do
      assert_selector "[data-dropdown-target='menu']:not(.hidden)", wait: 2
    end

    # Verify user email is displayed
    assert_text @user.email

    # Verify account type is displayed
    assert_text "Patient Account"

    # Click outside to close
    find("body").click

    # Verify dropdown is hidden
    within user_dropdown do
      assert_selector "[data-dropdown-target='menu'].hidden", visible: :all, wait: 3
    end
  end

  test "provider sees provider account type in profile dropdown" do
    sign_in @provider
    visit root_path

    # Click user avatar
    find("[data-dropdown-target='button'][aria-label='User menu']").click

    # Verify account type shows Provider
    assert_text "Provider Account"
  end

  test "notification dropdown shows empty state when no notifications" do
    Notification.where(user: @user).delete_all

    sign_in @user
    visit root_path

    # Click notification bell
    find("[data-dropdown-target='button'][aria-label='View notifications']").click

    # Verify empty state message
    assert_text "All caught up!"
    assert_text "You have no new notifications"
  end

  test "notification dropdown shows unread badge when notifications exist" do
    Notification.where(user: @user).delete_all

    # Create a notification for the user
    Notification.create!(
      user: @user,
      title: "Test Notification",
      message: "This is a test notification",
      notification_type: "system_announcement"
    )

    sign_in @user
    visit root_path

    # Verify unread badge is visible
    assert_selector "button[aria-label='View notifications'] span.bg-gradient-to-br.from-teal-500.to-teal-600"

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
    user_button = find("[data-dropdown-target='button'][aria-label='User menu']")
    user_dropdown = user_button.find(:xpath, "./ancestor::div[@data-controller='dropdown'][1]")
    user_button.click

    # Click dashboard link (scope to the dropdown; the footer also has a link)
    within user_dropdown do
      click_link "My Dashboard"
    end

    # Verify navigation to dashboard
    assert_current_path dashboard_path
  end

  test "notification dropdown closes on escape key" do
    sign_in @user
    visit root_path

    notification_button = find("[data-dropdown-target='button'][aria-label='View notifications']")
    notification_dropdown = notification_button.find(:xpath, "./ancestor::div[@data-controller='dropdown'][1]")

    # Click notification bell
    notification_button.click

    # Verify dropdown is open
    assert_selector "[data-dropdown-target='menu']:not(.hidden)"

    # Press Escape key
    find("body").send_keys(:escape)

    # Verify dropdown is closed
    within notification_dropdown do
      assert_selector "[data-dropdown-target='menu'].hidden", visible: :all, wait: 3
    end
  end

  test "profile dropdown closes on escape key" do
    sign_in @user
    visit root_path

    user_button = find("[data-dropdown-target='button'][aria-label='User menu']")
    user_dropdown = user_button.find(:xpath, "./ancestor::div[@data-controller='dropdown'][1]")

    # Ensure the dropdown menu is initialized/hidden before we try to open it.
    within user_dropdown do
      assert_selector "[data-dropdown-target='menu'].hidden", visible: :all
    end

    # Open dropdown. In headless runs, the click handler can be flaky due to
    # pending animation timeouts from earlier dropdown interactions.
    page.execute_script(<<~JS)
      const btn = document.querySelector('[data-dropdown-target="button"][aria-label="User menu"]');
      const dropdown = btn?.closest('[data-controller*="dropdown"]');
      dropdown?.dropdownController?.open?.();
    JS

    # Verify dropdown is open
    within user_dropdown do
      assert_selector "[data-dropdown-target='menu']:not(.hidden)", wait: 2
    end

    # Press Escape key
    find("body").send_keys(:escape)

    # Verify dropdown is closed
    within user_dropdown do
      assert_selector "[data-dropdown-target='menu'].hidden", visible: :all, wait: 3
    end
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

end
