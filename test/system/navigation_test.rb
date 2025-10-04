require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
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
      assert_link "Home"
      assert_text "Services"
      assert_link "Providers"
      assert_text "About"
    end
  end

  test "services dropdown menu opens and displays items" do
    visit root_path
    
    # Click Services dropdown
    find("button", text: "Services").click
    
    # Check dropdown items are visible
    assert_text "Browse All Services"
    assert_text "Find Providers"
    assert_text "Book Appointment"
  end

  test "about dropdown menu opens and displays items" do
    visit root_path
    
    # Click About dropdown
    find("button", text: "About").click
    
    # Check dropdown items are visible
    assert_text "About Us"
    assert_text "How It Works"
    assert_text "Contact Us"
  end

  test "mobile menu button is visible on small screens" do
    visit root_path
    
    # Mobile menu button should exist
    assert_selector "button[aria-label='Toggle menu']"
  end

  # Navbar Tests - Logged In
  test "navbar shows user profile when logged in" do
    sign_in @user
    visit root_path
    
    within "nav" do
      assert_text @user.first_name
      assert_selector "div", text: @user.first_name.first.upcase # Avatar
    end
  end

  test "navbar shows notifications bell when logged in" do
    sign_in @user
    visit root_path
    
    assert_selector "button[aria-label='Notifications']"
    assert_selector "svg" # Bell icon
  end

  test "notifications dropdown opens and displays items" do
    sign_in @user
    visit root_path
    
    # Click notifications bell
    find("button[aria-label='Notifications']").click
    
    # Check dropdown content
    assert_text "Notifications"
    assert_text "View all notifications"
  end

  test "user profile dropdown opens and displays menu items" do
    sign_in @user
    visit root_path
    
    # Click user profile
    find("button[aria-label='User menu']").click
    
    # Check dropdown items
    assert_text @user.email
    assert_text @user.role.titleize
    assert_text "My Profile"
    assert_text "My Appointments"
    assert_text "Billing"
    assert_text "Settings"
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
    
    assert_no_link "Sign In"
    assert_no_link "Get Started"
  end

  # Footer Tests
  test "footer displays company information" do
    visit root_path
    
    within "footer" do
      assert_text "WellnessConnect"
      assert_text "Connecting you with expert wellness providers"
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
      assert_text "Quick Links"
      assert_link "Home"
      assert_link "Browse Services"
      assert_link "Find Providers"
      assert_link "Book Appointment"
      assert_link "How It Works"
    end
  end

  test "footer displays support section" do
    visit root_path
    
    within "footer" do
      assert_text "Support"
      assert_link "Help Center"
      assert_link "Contact Us"
      assert_link "FAQs"
      assert_link "Safety & Privacy"
      assert_link "Accessibility"
    end
  end

  test "footer displays legal section" do
    visit root_path
    
    within "footer" do
      assert_text "Legal"
      assert_link "Terms of Service"
      assert_link "Privacy Policy"
      assert_link "Cookie Policy"
      assert_link "HIPAA Compliance"
      assert_link "Provider Agreement"
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
      assert_text "SSL Secured"
    end
  end

  # Accessibility Tests
  test "navbar has proper ARIA attributes" do
    visit root_path
    
    # Check for aria-label on icon buttons
    assert_selector "button[aria-label='Toggle menu']"
    
    # Check for aria-expanded on dropdown buttons
    assert_selector "button[aria-expanded='false']"
  end

  test "navbar is keyboard navigable" do
    visit root_path
    
    # Tab through navigation elements
    find("body").send_keys(:tab)
    
    # Logo should be focused
    assert_equal root_path, evaluate_script("document.activeElement.getAttribute('href')")
  end

  test "dropdowns have proper aria-haspopup attribute" do
    visit root_path
    
    assert_selector "button[aria-haspopup='true']"
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
    fill_in "Email Address", with: user.email
    fill_in "user_password", with: "password123"
    click_button "Sign In"
  end
end

