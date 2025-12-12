require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  DEFAULT_PASSWORD = "password12345"

  setup do
    @user = User.create!(
      email: "test@example.com",
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD,
      first_name: "John",
      last_name: "Doe",
      role: "patient"
    )
  end

  # Navbar Tests - Logged Out
  test "navbar displays logo and brand name" do
    visit root_path

    assert_selector "nav"
    assert_text "WellnessConnect"
    assert_selector "svg" # Logo icon
  end

  test "navbar shows sign in and get started buttons when logged out" do
    visit root_path

    assert_link "Sign In"
    assert_link "Get Started"
  end

  test "navbar displays main navigation links" do
    visit root_path

    within "nav" do
      assert_link "Browse Providers"
      assert_link "About"
      assert_link "Become a Provider"
    end
  end

  test "mobile menu button is visible on small screens" do
    visit root_path

    # Mobile menu button should exist
    assert_selector "button[aria-label='Toggle navigation menu']", visible: :all
  end

  # Navbar Tests - Logged In
  test "navbar shows user profile when logged in" do
    sign_in @user
    visit root_path

    within "nav" do
      assert_selector "button[aria-label='User menu']"
    end
  end

  test "navbar shows notifications bell when logged in" do
    sign_in @user
    visit root_path

    assert_selector "button[aria-label='View notifications']"
    assert_selector "svg" # Bell icon
  end

  test "notifications dropdown opens and displays items" do
    sign_in @user
    visit root_path

    # Click notifications bell
    find("button[aria-label='View notifications']").click

    # Check dropdown content
    assert_text "Notifications"
    assert_text "All caught up!"
  end

  test "user profile dropdown opens and displays menu items" do
    sign_in @user
    visit root_path

    # Click user profile
    find("button[aria-label='User menu']").click

    # Check dropdown items
    assert_text @user.email
    assert_text "Patient Account"
    assert_text "Notification Settings"
    assert_text "Messages"
    assert_text "My Dashboard"
    assert_button "Sign Out"
  end

  test "user can sign out from profile dropdown" do
    sign_in @user
    visit root_path

    # Open profile dropdown
    find("button[aria-label='User menu']").click

    # Click sign out
    click_button "Sign Out"

    # Should redirect to home and show sign in button
    assert_link "Sign In"
    assert_link "Get Started"
  end

  test "navbar does not show sign in buttons when logged in" do
    sign_in @user
    visit root_path

    within "nav" do
      assert_no_link "Sign In"
      assert_no_link "Get Started"
    end
  end

  # Footer Tests
  test "footer displays company information" do
    visit root_path

    within "footer" do
      assert_text "WellnessConnect"
      assert_text "Connecting patients with trusted healthcare providers"
    end
  end

  test "footer displays social media links" do
    visit root_path

    within "footer" do
      assert_selector "a[aria-label='Facebook']"
      assert_selector "a[aria-label='Twitter']"
      assert_selector "a[aria-label='LinkedIn']"
      assert_selector "a[aria-label='Instagram']"
    end
  end

  test "footer displays quick links section" do
    visit root_path

    within "footer" do
      assert_text "QUICK LINKS"
      assert_link "Browse Providers"
      assert_link "About Us"
      assert_link "Contact"
    end
  end

  test "footer displays resources and legal section" do
    visit root_path

    within "footer" do
      assert_text "RESOURCES & LEGAL"
      assert_link "Help Center"
      assert_link "Privacy Policy"
      assert_link "Terms of Service"
      assert_link "HIPAA Compliance"
      assert_link "FAQ"
    end
  end

  test "footer displays copyright with current year" do
    visit root_path

    within "footer" do
      assert_text "© #{Time.current.year} WellnessConnect. All rights reserved."
    end
  end

  test "footer displays trust badges" do
    visit root_path

    within "footer" do
      assert_text "HIPAA Compliant"
      assert_text "256-bit SSL"
    end
  end

  # Accessibility Tests
  test "navbar has proper ARIA attributes" do
    visit root_path

    # Check for aria-label on icon buttons
    assert_selector "button[aria-label='Toggle navigation menu']", visible: :all

    # Check for aria-expanded on dropdown buttons
    assert_selector "button[aria-expanded='false']", visible: :all
  end

  test "navbar is keyboard navigable" do
    visit root_path

    # Tab through navigation elements
    find("body").send_keys(:tab)

    # Logo should be focused
    assert_equal root_path, evaluate_script("document.activeElement.getAttribute('href')")
  end

  test "dropdowns have proper aria-haspopup attribute" do
    sign_in @user
    visit root_path

    assert_selector "button[aria-haspopup='true']", minimum: 1
  end

  # Responsive Tests
  test "mobile menu is hidden by default" do
    visit root_path

    mobile_menu = find("[data-navbar-target='mobileMenu']", visible: false)
    assert mobile_menu[:class].include?("hidden")
  end

  test "navbar is fixed to top of page" do
    visit root_path

    nav = find("nav")
    assert nav[:class].include?("fixed")
    assert nav[:class].include?("top-0")
  end

  test "navbar has proper z-index for layering" do
    visit root_path

    nav = find("nav")
    assert nav[:class].include?("z-50")
  end

  # Integration Tests
  test "clicking logo navigates to home page" do
    visit "/about" # Assuming an about page exists

    within "nav" do
      click_link "WellnessConnect"
    end

    assert_current_path root_path
  end

  test "navbar persists across page navigation" do
    visit root_path

    # Navbar should be present
    assert_selector "nav"

    # Navigate to another page (if exists)
    # visit some_other_path

    # Navbar should still be present
    assert_selector "nav"
  end

  test "footer persists across page navigation" do
    visit root_path

    # Footer should be present
    assert_selector "footer"

    # Navigate to another page (if exists)
    # visit some_other_path

    # Footer should still be present
    assert_selector "footer"
  end

  private

  def sign_in(user)
    visit new_user_session_path
    within "form[action='#{user_session_path}']" do
      fill_in "Email Address", with: user.email
      fill_in "Password", with: DEFAULT_PASSWORD
      click_button "Sign In"
    end

    assert_selector "button[aria-label='User menu']"
  end
end
