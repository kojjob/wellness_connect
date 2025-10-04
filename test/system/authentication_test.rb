require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:patient_user)
  end

  test "visiting the sign in page" do
    visit new_user_session_path

    assert_selector "h2", text: "Sign In"
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"
    assert_selector "input[type='checkbox']" # Remember me
    assert_link "Forgot password?"
    assert_link "Create an Account"
  end

  test "signing in with valid credentials" do
    visit new_user_session_path

    fill_in "Email Address", with: @user.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    assert_text "Signed in successfully"
  end

  test "signing in with invalid credentials" do
    visit new_user_session_path

    fill_in "Email Address", with: @user.email
    fill_in "Password", with: "wrongpassword"
    click_button "Sign In"

    assert_text "Invalid Email or password"
  end

  test "visiting the sign up page" do
    visit new_user_registration_path

    assert_selector "h2", text: "Create Account"
    assert_selector "input[name='user[first_name]']"
    assert_selector "input[name='user[last_name]']"
    assert_selector "input[type='email']"
    assert_selector "input[type='password']", count: 2 # Password and confirmation
    assert_selector "input[type='radio'][value='patient']"
    assert_selector "input[type='radio'][value='provider']"
    assert_selector "input[type='checkbox']#terms"
    assert_link "Sign In Instead"
  end

  test "signing up with valid information" do
    visit new_user_registration_path

    fill_in "First Name", with: "Jane"
    fill_in "Last Name", with: "Smith"
    fill_in "Email Address", with: "jane.smith@example.com"
    fill_in "user_password", with: "SecurePassword123!"
    fill_in "Confirm Password", with: "SecurePassword123!"
    find("label", text: "Client").click
    check "terms"

    click_button "Create Account"

    assert_text "Welcome! You have signed up successfully"
  end

  test "signing up with invalid email" do
    visit new_user_registration_path

    # Remove HTML5 email validation to test server-side validation
    page.execute_script("document.querySelector('input[type=email]').type = 'text'")

    fill_in "First Name", with: "Jane"
    fill_in "Last Name", with: "Smith"
    fill_in "Email Address", with: "invalid" # Invalid - no @ symbol
    fill_in "user_password", with: "SecurePassword123!"
    fill_in "Confirm Password", with: "SecurePassword123!"
    check "terms"

    click_button "Create Account"

    # Check for error message (Devise's default message)
    assert_selector "#error_explanation"
    assert_text "prohibited this user from being saved"
  end

  test "signing up with password mismatch" do
    visit new_user_registration_path

    fill_in "First Name", with: "Jane"
    fill_in "Last Name", with: "Smith"
    fill_in "Email Address", with: "jane.smith@example.com"
    fill_in "user_password", with: "SecurePassword123!"
    fill_in "Confirm Password", with: "DifferentPassword123!"
    check "terms"

    click_button "Create Account"

    assert_text "Password confirmation doesn't match Password"
  end

  test "password strength indicator updates" do
    visit new_user_registration_path

    # Test weak password
    fill_in "user_password", with: "weak"
    assert_selector "[data-password-target='strengthText']", text: "Weak"

    # Test strong password
    fill_in "user_password", with: "StrongPassword123!"
    assert_selector "[data-password-target='strengthText']", text: "Strong"
  end

  test "password visibility toggle works" do
    visit new_user_registration_path

    password_field = find("input[name='user[password]']")
    assert_equal "password", password_field[:type]

    # Click toggle button
    within first("[data-controller='password']") do
      find("[data-password-target='toggle']").click
    end

    assert_equal "text", password_field[:type]
  end

  test "visiting the forgot password page" do
    visit new_user_password_path

    assert_selector "h2", text: "Forgot Password?"
    assert_selector "input[type='email']"
    assert_button "Send Reset Instructions"
    assert_link "Back to Sign In"
  end

  test "requesting password reset with valid email" do
    visit new_user_password_path

    fill_in "Email Address", with: @user.email
    click_button "Send Reset Instructions"

    # Paranoid mode shows generic message
    assert_text "If your email address exists in our database, you will receive a password recovery link"
  end

  test "requesting password reset with invalid email" do
    visit new_user_password_path

    fill_in "Email Address", with: "nonexistent@example.com"
    click_button "Send Reset Instructions"

    # Devise paranoid mode shows the same message for security reasons
    assert_text "If your email address exists in our database, you will receive a password recovery link"
  end

  test "sign up page displays role selection" do
    visit new_user_registration_path

    assert_selector "label", text: "Client"
    assert_selector "label", text: "Provider"

    # Default should be patient/client
    assert find("input[value='patient']").checked?
  end

  test "can select provider role during sign up" do
    visit new_user_registration_path

    find("label", text: "Provider").click

    assert find("input[value='provider']").checked?
  end

  test "sign in page has proper accessibility attributes" do
    visit new_user_session_path

    # Check for aria-labels
    assert_selector "input[aria-label='Email address']"
    assert_selector "input[aria-label='Password']"
    assert_selector "button[aria-label='Toggle password visibility']"
  end

  test "sign up page has proper accessibility attributes" do
    visit new_user_registration_path

    # Check for aria-labels
    assert_selector "input[aria-label='First name']"
    assert_selector "input[aria-label='Last name']"
    assert_selector "input[aria-label='Email address']"
    assert_selector "input[aria-label='Password']"
    assert_selector "input[aria-label='Confirm password']"
  end

  test "error messages are displayed with proper styling" do
    visit new_user_registration_path

    # Fill form with data that will trigger Rails validation errors
    fill_in "First Name", with: "Jane"
    fill_in "Last Name", with: "Smith"
    fill_in "Email Address", with: "jane@example.com"
    fill_in "user_password", with: "short" # Too short, triggers validation
    fill_in "Confirm Password", with: "different" # Doesn't match, triggers validation
    check "terms"

    click_button "Create Account"

    # Check for error message container
    assert_selector "#error_explanation"
    assert_selector ".bg-red-50" # Tailwind error styling
    assert_selector "svg.text-red-500" # Error icon
  end

  test "navigation between auth pages works" do
    # Start at sign in
    visit new_user_session_path
    assert_selector "h2", text: "Sign In"

    # Go to sign up
    click_link "Create an Account"
    assert_selector "h2", text: "Create Account"

    # Go back to sign in
    click_link "Sign In Instead"
    assert_selector "h2", text: "Sign In"

    # Go to forgot password
    click_link "Forgot password?"
    assert_selector "h2", text: "Forgot Password?"

    # Go back to sign in
    click_link "Back to Sign In"
    assert_selector "h2", text: "Sign In"
  end

  test "remember me checkbox is present and functional" do
    visit new_user_session_path

    remember_me_checkbox = find("input[name='user[remember_me]']")
    assert_not remember_me_checkbox.checked?

    check "Remember me"
    assert remember_me_checkbox.checked?
  end

  test "terms checkbox is required for sign up" do
    visit new_user_registration_path

    fill_in "First Name", with: "Jane"
    fill_in "Last Name", with: "Smith"
    fill_in "Email Address", with: "jane.smith@example.com"
    fill_in "user_password", with: "SecurePassword123!"
    fill_in "Confirm Password", with: "SecurePassword123!"

    # Don't check terms
    # The browser should prevent submission due to required attribute
    terms_checkbox = find("input#terms")
    assert terms_checkbox[:required]
  end
end
