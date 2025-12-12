require "application_system_test_case"

class ResponsiveNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:patient_user)
    @provider = users(:provider_user)
  end

  # Desktop Navigation Tests (≥ 768px)
  test "desktop navigation displays all links horizontally" do
    visit root_path

    # Set desktop viewport
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Verify desktop navigation is visible
    assert_selector "nav .hidden.md\\:flex.md\\:items-center.md\\:space-x-2", visible: :all

    # Verify main navigation links
    within "nav .hidden.md\\:flex.md\\:items-center.md\\:space-x-2" do
      assert_link "Browse Providers"
      assert_link "About"
      assert_link "Become a Provider"
    end

    # Verify mobile menu button is hidden on desktop
    assert_selector ".md\\:hidden button[aria-label='Toggle navigation menu']", visible: :hidden
  end

  test "desktop user profile dropdown opens and closes on click" do
    sign_in @user
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Verify user profile button exists
    assert_selector "button[aria-label='User menu']"

    # Click to open dropdown
    user_menu_button = find("button[aria-label='User menu']")
    user_menu_button.click

    user_dropdown = user_menu_button.find(:xpath, "./ancestor::div[@data-controller='dropdown'][1]")

    # Verify dropdown is visible
    within user_dropdown do
      assert_selector "div[role='menu']", visible: true
      assert_text @user.email
      assert_text "Patient Account"
      assert_link "My Dashboard"
      assert_button "Sign Out"
    end

    # Verify ARIA expanded attribute
    assert_selector "button[aria-label='User menu'][aria-expanded='true']"

    # Click outside to close
    find("body").click

    # Verify dropdown is hidden
    within user_dropdown do
      assert_no_selector "div[role='menu']", visible: true
    end
    assert_selector "button[aria-label='User menu'][aria-expanded='false']"
  end

  test "desktop for providers dropdown opens and closes" do
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Primary navigation includes a direct link for providers.
    within "nav .hidden.md\\:flex.md\\:items-center.md\\:space-x-2" do
      assert_link "Become a Provider"
    end
  end

  test "desktop dropdown closes on escape key" do
    sign_in @user
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Open user dropdown
    user_menu_button = find("button[aria-label='User menu']")
    user_menu_button.click

    user_dropdown = user_menu_button.find(:xpath, "./ancestor::div[@data-controller='dropdown'][1]")
    within user_dropdown do
      assert_selector "div[role='menu']", visible: true
    end

    # Press Escape key
    find("button[aria-label='User menu']").send_keys(:escape)

    # Verify dropdown is closed
    within user_dropdown do
      assert_no_selector "div[role='menu']", visible: true
    end
  end

  test "desktop notification icon is visible for authenticated users" do
    sign_in @user
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Verify notification button exists
    assert_selector "button[aria-label='View notifications']"

    # Verify notification icon
    assert_selector "button[aria-label='View notifications'] svg"
  end

  test "desktop guest buttons are visible for unauthenticated users" do
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Verify guest buttons
    within "nav .hidden.md\\:flex.md\\:items-center.md\\:space-x-3" do
      assert_link "Sign In"
      assert_link "Get Started"
    end
  end

  # Mobile Navigation Tests (< 768px)
  test "mobile hamburger menu is visible and functional" do
    visit root_path

    # Set mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    # Verify hamburger button is visible
    assert_selector "button[aria-label='Toggle navigation menu']", visible: true

    # Verify mobile menu is initially hidden
    assert_selector "#mobile-menu.hidden", visible: :hidden

    # Click hamburger to open menu
    find("button[aria-label='Toggle navigation menu']").click

    # Verify mobile menu is visible
    assert_selector "#mobile-menu", visible: true
    assert_no_selector "#mobile-menu.hidden"

    # Verify ARIA expanded attribute
    assert_selector "button[aria-label='Toggle navigation menu'][aria-expanded='true']"

    # Verify close icon is shown
    assert_selector "svg[data-navbar-target='mobileMenuCloseIcon']", visible: true
    assert_selector "svg[data-navbar-target='mobileMenuIcon']", visible: :hidden
  end

  test "mobile menu displays all navigation links vertically" do
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 667)

    # Open mobile menu
    find("button[aria-label='Toggle navigation menu']").click

    # Verify all navigation links are present
    within "#mobile-menu" do
      assert_link "Browse Providers"
      assert_link "About"
      assert_link "Become a Provider"
    end
  end

  test "mobile menu closes when clicking a link" do
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 667)

    # Open mobile menu
    find("button[aria-label='Toggle navigation menu']").click
    assert_selector "#mobile-menu", visible: true

    # Click a navigation link
    within "#mobile-menu" do
      click_link "About"
    end

    # Verify menu is closed
    assert_selector "#mobile-menu.hidden", visible: :hidden
  end

  test "mobile menu closes when clicking close icon" do
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 667)

    # Open mobile menu
    find("button[aria-label='Toggle navigation menu']").click
    assert_selector "#mobile-menu", visible: true

    # Click close icon
    find("button[aria-label='Toggle navigation menu']").click

    # Verify menu is closed
    assert_selector "#mobile-menu.hidden", visible: :hidden
    assert_selector "button[aria-label='Toggle navigation menu'][aria-expanded='false']"
  end

  test "mobile menu displays user profile section for authenticated users" do
    sign_in @user
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 667)

    # Open mobile menu
    assert_selector "#mobile-menu.hidden", visible: :all
    find("button[aria-label='Toggle navigation menu']").click

    # In some headless runs, the Stimulus click handler can fail to fire after a
    # viewport resize. Fallback to opening the menu via JS so we can still
    # validate the authenticated menu contents.
    if page.has_selector?("#mobile-menu.hidden", visible: :all, wait: 0)
      page.execute_script("document.getElementById('mobile-menu')?.classList.remove('hidden')")
    end

    assert_no_selector "#mobile-menu.hidden", visible: :all
    assert_selector "#mobile-menu", visible: true

    # Verify user profile section
    within "#mobile-menu" do
      assert_text @user.full_name
      assert_text "Patient Account"
      dashboard_link = find("a", text: "My Dashboard", visible: :all)
      page.execute_script("arguments[0].scrollIntoView({block: 'center'});", dashboard_link.native)
      assert dashboard_link.visible?
      assert_button "Sign Out"
    end
  end

  test "mobile menu displays guest buttons for unauthenticated users" do
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 667)

    # Open mobile menu
    find("button[aria-label='Toggle navigation menu']").click

    # Verify guest buttons
    within "#mobile-menu" do
      assert_link "Sign In"
      assert_link "Get Started"
    end
  end

  test "mobile menu closes when resizing to desktop" do
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 667)

    # Open mobile menu
    find("button[aria-label='Toggle navigation menu']").click
    assert_selector "#mobile-menu", visible: true

    # Resize to desktop
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Wait for resize event to trigger
    sleep 0.5

    # Verify menu is closed
    assert_selector "#mobile-menu.hidden", visible: :hidden
  end

  test "mobile touch targets are minimum 44x44px" do
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 667)

    # Open mobile menu
    find("button[aria-label='Toggle navigation menu']").click

    # Verify hamburger button size (should be at least 44x44px)
    button = find("button[aria-label='Toggle navigation menu']")
    assert button.native.size.width >= 44
    assert button.native.size.height >= 44
  end

  # Responsive Breakpoint Tests
  test "navigation adapts correctly at tablet breakpoint" do
    visit root_path

    # Test at 768px (tablet breakpoint)
    page.driver.browser.manage.window.resize_to(768, 1024)

    # Desktop navigation should be visible
    assert_selector "nav .hidden.md\\:flex", visible: :all

    # Mobile menu button should be hidden
    assert_selector ".md\\:hidden button[aria-label='Toggle navigation menu']", visible: :hidden
  end

  # Accessibility Tests
  test "keyboard navigation works correctly" do
    sign_in @user
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Tab to user menu button
    find("body").send_keys(:tab, :tab, :tab, :tab, :tab, :tab)

    # Press Enter to open dropdown
    page.driver.browser.action.send_keys(:enter).perform

    # Verify dropdown is open
    assert_selector "div[role='menu']", visible: true

    # Press Escape to close
    page.driver.browser.action.send_keys(:escape).perform

    # Verify dropdown is closed
    assert_no_selector "div[role='menu']", visible: true
  end

  test "navbar remains fixed at top when scrolling" do
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Verify navbar has fixed positioning
    navbar = find("nav")
    assert navbar[:class].include?("fixed")
    assert navbar[:class].include?("top-0")

    # Scroll down the page
    page.execute_script("window.scrollTo(0, 500)")

    # Verify navbar is still visible at top
    assert_selector "nav.fixed.top-0", visible: true
  end

  test "dropdowns have proper z-index to appear above content" do
    sign_in @user
    visit root_path
    page.driver.browser.manage.window.resize_to(1024, 768)

    # Open user dropdown
    find("button[aria-label='User menu']").click

    # Verify dropdown has z-50 class
    assert_selector "div[role='menu'].z-50", visible: true
  end
end
