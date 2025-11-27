require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  def setup
    @user = users(:patient_user)
    @provider = users(:provider_user)
  end

  # === Appointment Booked Email Tests ===
  test "appointment_booked email" do
    email = NotificationMailer.appointment_booked(
      @user,
      "New Appointment Booked",
      "Your appointment has been confirmed for January 15, 2025 at 10:00 AM"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "noreply@wellnessconnect.com" ], email.from
    assert_equal [ @user.email ], email.to
    assert_equal "New Appointment Booked", email.subject
    assert_match "Your appointment has been confirmed", email.body.encoded
  end

  # === Appointment Cancelled Email Tests ===
  test "appointment_cancelled email" do
    email = NotificationMailer.appointment_cancelled(
      @user,
      "Appointment Cancelled",
      "Your appointment scheduled for January 15, 2025 has been cancelled"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "Appointment Cancelled", email.subject
    assert_match "Appointment Cancelled", email.html_part.body.to_s
    assert_match "cancelled", email.text_part.body.to_s
  end

  # === Appointment Reminder Email Tests ===
  test "appointment_reminder email" do
    email = NotificationMailer.appointment_reminder(
      @user,
      "Appointment Reminder",
      "You have an appointment tomorrow at 10:00 AM"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "Appointment Reminder", email.subject
    assert_match "tomorrow", email.body.encoded
  end

  # === Payment Received Email Tests ===
  test "payment_received email" do
    email = NotificationMailer.payment_received(
      @provider,
      "Payment Received",
      "You received a payment of $150.00"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "Payment Received", email.subject
    assert_match "$150.00", email.body.encoded
  end

  # === Payment Failed Email Tests ===
  test "payment_failed email" do
    email = NotificationMailer.payment_failed(
      @user,
      "Payment Failed",
      "Your payment could not be processed. Please update your payment method."
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "Payment Failed", email.subject
    assert_match "could not be processed", email.body.encoded
  end

  # === Refund Processed Email Tests ===
  test "refund_processed email" do
    email = NotificationMailer.refund_processed(
      @user,
      "Refund Processed",
      "Your refund of $75.00 has been processed"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "Refund Processed", email.subject
    assert_match "$75.00", email.body.encoded
  end

  # === Profile Approved Email Tests ===
  test "profile_approved email" do
    email = NotificationMailer.profile_approved(
      @provider,
      "Profile Approved",
      "Congratulations! Your provider profile has been approved"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "Profile Approved", email.subject
    assert_match "Congratulations", email.body.encoded
  end

  # === New Review Email Tests ===
  test "new_review email" do
    email = NotificationMailer.new_review(
      @provider,
      "New Review Received",
      "You have received a new 5-star review"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "New Review Received", email.subject
    assert_match "review", email.body.encoded
  end

  # === System Announcement Email Tests ===
  test "system_announcement email" do
    email = NotificationMailer.system_announcement(
      @user,
      "System Maintenance",
      "We will be performing maintenance on Sunday from 2-4 AM"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "System Maintenance", email.subject
    assert_match "maintenance", email.body.encoded
  end

  # === Generic Notification Email Tests ===
  test "notification email with custom content" do
    email = NotificationMailer.notification(
      @user,
      "Custom Notification",
      "This is a custom notification message"
    )

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal "Custom Notification", email.subject
    assert_match "custom notification message", email.body.encoded
  end

  # === Email Format Tests ===
  test "email includes user name" do
    email = NotificationMailer.notification(
      @user,
      "Test",
      "Test message"
    )

    assert_match @user.first_name, email.body.encoded
  end

  test "email includes WellnessConnect branding" do
    email = NotificationMailer.notification(
      @user,
      "Test",
      "Test message"
    )

    assert_match "WellnessConnect", email.body.encoded
  end

  test "email has both HTML and text parts" do
    email = NotificationMailer.notification(
      @user,
      "Test",
      "Test message"
    )

    assert_equal 2, email.parts.length
    assert_equal "text/plain", email.parts[0].content_type.split(";").first
    assert_equal "text/html", email.parts[1].content_type.split(";").first
  end
end
