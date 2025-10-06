require "test_helper"

class MessageTest < ActiveSupport::TestCase
  # Fixtures
  def setup
    @conversation = conversations(:general_conversation)
    @patient = users(:patient_user)
    @provider = users(:provider_user)
  end

  # Association Tests
  test "should belong to conversation" do
    message = Message.new(conversation: @conversation, sender: @patient, content: "Hello")
    assert_equal @conversation, message.conversation
  end

  test "should belong to sender" do
    message = Message.new(conversation: @conversation, sender: @patient, content: "Hello")
    assert_equal @patient, message.sender
  end

  test "should have one attached attachment" do
    message = messages(:text_message)
    assert_respond_to message, :attachment
  end

  # Validation Tests
  test "should not save without conversation" do
    message = Message.new(sender: @patient, content: "Hello")
    assert_not message.save, "Saved message without conversation"
    assert_includes message.errors[:conversation], "must exist"
  end

  test "should not save without sender" do
    message = Message.new(conversation: @conversation, content: "Hello")
    assert_not message.save, "Saved message without sender"
    assert_includes message.errors[:sender], "must exist"
  end

  test "should not save without content and attachment" do
    message = Message.new(conversation: @conversation, sender: @patient)
    assert_not message.save, "Saved message without content or attachment"
    assert_includes message.errors[:base], "Message must have either content or attachment"
  end

  test "should save with content only" do
    message = Message.new(
      conversation: @conversation,
      sender: @patient,
      content: "This is a test message",
      message_type: :text
    )
    assert message.save, "Failed to save message with content"
  end

  test "should save with attachment only" do
    message = Message.new(
      conversation: @conversation,
      sender: @patient,
      message_type: :file
    )
    message.attachment.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_document.pdf")),
      filename: "test_document.pdf",
      content_type: "application/pdf"
    )
    assert message.save, "Failed to save message with attachment"
  end

  test "should save with both content and attachment" do
    message = Message.new(
      conversation: @conversation,
      sender: @patient,
      content: "Here's the document",
      message_type: :file
    )
    message.attachment.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_document.pdf")),
      filename: "test_document.pdf",
      content_type: "application/pdf"
    )
    assert message.save, "Failed to save message with content and attachment"
  end

  test "should validate sender is participant of conversation" do
    other_user = users(:patient_user_two)  # Not a participant in @conversation
    message = Message.new(
      conversation: @conversation,
      sender: other_user,
      content: "Unauthorized message"
    )

    assert_not message.save, "Saved message from non-participant"
    assert_includes message.errors[:sender], "must be a participant in the conversation"
  end

  # Enum Tests
  test "should have message_type enum" do
    message = Message.new(
      conversation: @conversation,
      sender: @patient,
      content: "Test"
    )

    assert_respond_to message, :message_type
    assert_respond_to message, :text?
    assert_respond_to message, :file?
    assert_respond_to message, :image?
    assert_respond_to message, :system?
  end

  test "should default to text message_type" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Test message"
    )

    assert message.text?, "Message type should default to text"
  end

  # Encryption Tests
  test "content should be encrypted in database" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Sensitive information"
    )

    # Read directly from database to check encryption
    db_record = ActiveRecord::Base.connection.execute(
      "SELECT content FROM messages WHERE id = #{message.id}"
    ).first

    # Encrypted content should not match plain text
    assert_not_equal "Sensitive information", db_record["content"],
                     "Content should be encrypted in database"
  end

  test "content should be decrypted when reading from model" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Sensitive information"
    )

    # Reading from model should decrypt automatically
    message.reload
    assert_equal "Sensitive information", message.content,
                 "Content should be decrypted when reading from model"
  end

  # Scope Tests
  test "ordered scope should sort by created_at ascending" do
    # Create messages with explicit timestamps
    old_message = nil
    new_message = nil

    travel_to 1.hour.ago do
      old_message = Message.create!(
        conversation: @conversation,
        sender: @patient,
        content: "Old message"
      )
    end

    travel_to 1.minute.ago do
      new_message = Message.create!(
        conversation: @conversation,
        sender: @provider,
        content: "New message"
      )
    end

    ordered_messages = Message.where(id: [old_message.id, new_message.id]).ordered
    assert_equal old_message.id, ordered_messages.first.id, "Oldest message should be first"
    assert_equal new_message.id, ordered_messages.last.id, "Newest message should be last"
  end

  test "unread scope should only include messages where read_at is nil" do
    read_message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Read message",
      read_at: 1.hour.ago
    )
    unread_message = Message.create!(
      conversation: @conversation,
      sender: @provider,
      content: "Unread message",
      read_at: nil
    )

    unread_messages = Message.unread
    assert_includes unread_messages, unread_message
    assert_not_includes unread_messages, read_message
  end

  test "from_sender scope should only include messages from specified sender" do
    patient_message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "From patient"
    )
    provider_message = Message.create!(
      conversation: @conversation,
      sender: @provider,
      content: "From provider"
    )

    patient_messages = Message.from_sender(@patient)
    assert_includes patient_messages, patient_message
    assert_not_includes patient_messages, provider_message
  end

  test "by_type scope should only include messages of specified type" do
    text_message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Text message",
      message_type: :text
    )
    system_message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Appointment confirmed",
      message_type: :system
    )

    text_messages = Message.by_type(:text)
    assert_includes text_messages, text_message
    assert_not_includes text_messages, system_message
  end

  # Callback Tests
  test "should update conversation last_message_at after create" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      last_message_at: nil
    )

    freeze_time do
      Message.create!(
        conversation: conversation,
        sender: @patient,
        content: "New message"
      )

      conversation.reload
      assert_in_delta Time.current, conversation.last_message_at, 1.second
    end
  end

  test "should increment unread count for recipient after create" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 0,
      provider_unread_count: 0
    )

    # Provider sends message - should increment patient's unread count
    Message.create!(
      conversation: conversation,
      sender: @provider,
      content: "Message from provider"
    )

    conversation.reload
    assert_equal 1, conversation.patient_unread_count
    assert_equal 0, conversation.provider_unread_count
  end

  test "should broadcast to conversation channel after create" do
    # This would require Action Cable testing setup
    # Placeholder for future implementation
    skip "Action Cable testing not yet configured"
  end

  # Instance Method Tests
  test "mark_as_read should set read_at timestamp" do
    message = Message.create!(
      conversation: @conversation,
      sender: @provider,
      content: "Unread message",
      read_at: nil
    )

    assert_nil message.read_at

    freeze_time do
      message.mark_as_read
      assert_in_delta Time.current, message.read_at, 1.second
    end
  end

  test "mark_as_read should not change already read message" do
    original_read_time = 1.hour.ago
    message = Message.create!(
      conversation: @conversation,
      sender: @provider,
      content: "Already read",
      read_at: original_read_time
    )

    message.mark_as_read
    assert_in_delta original_read_time, message.read_at, 1.second
  end

  test "read? should return true if read_at is present" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Read message",
      read_at: 1.hour.ago
    )

    assert message.read?, "Message should be marked as read"
  end

  test "read? should return false if read_at is nil" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Unread message",
      read_at: nil
    )

    assert_not message.read?, "Message should be unread"
  end

  test "editable? should return true if message is less than 15 minutes old" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Recent message",
      created_at: 5.minutes.ago
    )

    assert message.editable?, "Recent message should be editable"
  end

  test "editable? should return false if message is more than 15 minutes old" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Old message",
      created_at: 20.minutes.ago
    )

    assert_not message.editable?, "Old message should not be editable"
  end

  test "recipient should return the other participant in conversation" do
    message = Message.create!(
      conversation: @conversation,
      sender: @patient,
      content: "Test message"
    )

    assert_equal @provider, message.recipient
  end
end
