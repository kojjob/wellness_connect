require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Disable transactional tests for system tests since they use a separate server
  # The test server and test runner have separate database connections
  self.use_transactional_tests = false

  # Include Devise helpers for system tests
  include Devise::Test::IntegrationHelpers

  # Clean up database after each test
  teardown do
    # Manually clean up all test data in dependency order (children first)
    ConsultationNote.delete_all if defined?(ConsultationNote)
    Payment.delete_all if defined?(Payment)
    Appointment.delete_all
    Review.delete_all if defined?(Review)
    Notification.delete_all if defined?(Notification)  # Delete notifications before users
    Availability.delete_all
    Service.delete_all
    ProviderProfile.delete_all
    PatientProfile.delete_all
    User.delete_all

    # Reload fixtures for next test
    self.class.fixtures :all
  end
end
