require "test_helper"

class MessageNotificationTest < ActiveSupport::TestCase
  def setup
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @conversation = conversations(:general_conversation)

    # Ensure notification preferences exist
    @patient.create_notification_preference! unless @patient.notification_preference
    @provider.create_notification_preference! unless @provider.notification_preference
  end

  test "creating a message sends notification to recipient" do
    assert_difference "Notification.count", 1 do
      Message.create!(
        conversation: @conversation,
        sender: @patient,
        content: "Hello, I have a question about my appointment",
        message_type: "text"
      )
    end

    notification = Notification.last
    assert_equal @provider, notification.user
    assert_equal "New Message from #{@patient.full_name}", notification.title
    assert_match @patient.full_name, notification.message
    assert_match "question about my appointment", notification.message
    assert_equal "new_message", notification.notification_type
  end

  test "message notification respects user preferences for in-app notifications" do
    # Disable in-app message notifications for provider
    @provider.notification_preference.update(in_app_messages: false)

    assert_no_difference "Notification.count" do
      Message.create!(
        conversation: @conversation,
        sender: @patient,
        content: "This should not create a notification",
        message_type: "text"
      )
    end
  end

  test "message notification includes conversation link" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Check the link",
      message_type: "text"
    )

    notification = Notification.last
    assert_includes notification.action_url, "conversations/#{@conversation.id}"
  end

  test "system messages do not create notifications" do
    assert_no_difference "Notification.count" do
      Message.create!(
        conversation: @conversation,
        sender: @patient,
        content: "System message",
        message_type: "system"
      )
    end
  end

  test "message notification truncates long messages" do
    long_message = "A" * 200
    
    Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: long_message,
      message_type: "text"
    )

    notification = Notification.last
    assert notification.message.length < long_message.length
    assert_match "...", notification.message
  end

  test "message with attachment shows attachment indicator" do
    message = Message.new(
      conversation: @conversation,
      sender: @patient,
      message_type: "file"
    )
    
    # Attach a file
    message.attachment.attach(
      io: StringIO.new("test file content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    
    assert_difference "Notification.count", 1 do
      message.save!
    end

    notification = Notification.last
    assert_match "[Attachment]", notification.message
  end

  test "provider sending message notifies patient" do
    assert_difference "Notification.count", 1 do
      Message.create!(
        conversation: @conversation,
        sender: @provider,
        content: "Response from provider",
        message_type: "text"
      )
    end

    notification = Notification.last
    assert_equal @patient, notification.user
    assert_equal "New Message from #{@provider.full_name}", notification.title
  end

  test "message notification includes sender full name" do
    Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Test message",
      message_type: "text"
    )

    notification = Notification.last
    assert_includes notification.title, @patient.full_name
    assert_includes notification.message, @patient.full_name
  end
end
