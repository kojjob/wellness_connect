require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Disable transactional tests for system tests since they use a separate server
  # The test server and test runner have separate database connections
  self.use_transactional_tests = false

  # Include Devise helpers for system tests
  include Devise::Test::IntegrationHelpers

  # NOTE: Devise's `sign_in` helper does not reliably authenticate the browser
  # session when using Selenium-driven system tests. Override it to sign in via
  # the UI so `user_signed_in?` is true in the rendered app.
  def sign_in(user, password: "password123")
    # Keep sign-in stable regardless of what prior tests did to the viewport.
    page.driver.browser.manage.window.resize_to(1400, 1400)

    visit new_user_session_path
    fill_in "Email Address", with: user.email
    fill_in "Password", with: password
    click_button "Sign In"
    assert_selector "button[aria-label='User menu']"
  end

  # Clean up database after each test
  teardown do
    # Manually clean up all test data in dependency order (children first, parents last)
    ConsultationNote.delete_all if defined?(ConsultationNote)
    Message.delete_all if defined?(Message)
    Conversation.delete_all if defined?(Conversation)
    Payment.delete_all if defined?(Payment)
    Appointment.delete_all
    Availability.delete_all
    Service.delete_all
    Review.delete_all if defined?(Review)
    ActiveStorage::VariantRecord.delete_all if defined?(ActiveStorage::VariantRecord)
    ActiveStorage::Attachment.delete_all
    ActiveStorage::Blob.delete_all
    ProviderProfile.delete_all
    PatientProfile.delete_all
    Notification.delete_all if defined?(Notification)
    NotificationPreference.delete_all if defined?(NotificationPreference)
    User.delete_all

    # Reload fixtures for next test
    self.class.fixtures :all
  end
end
