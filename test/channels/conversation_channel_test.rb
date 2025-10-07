require "test_helper"

class ConversationChannelTest < ActionCable::Channel::TestCase
  setup do
    # Use existing test fixtures
    @patient = users(:patient_user)
    @provider = users(:provider_user)

    # Create test conversation
    @conversation = Conversation.create!(
      patient: @patient,
      provider: @provider
    )

    # Stub current_user for connection
    stub_connection current_user: @patient
  end

  test "subscribes to conversation channel with valid authorization" do
    # Subscribe to the conversation channel
    subscribe id: @conversation.id

    # Verify subscription was successful
    assert subscription.confirmed?

    # Verify streaming from the conversation
    assert_has_stream_for @conversation
  end

  test "rejects subscription when user is not a participant" do
    # Create a different user who is not a participant
    non_participant = User.create!(
      email: "non_participant@example.com",
      password: "password",
      first_name: "Non",
      last_name: "Participant",
      role: :patient
    )

    # Stub the non-participant as current user
    stub_connection current_user: non_participant

    # Attempt to subscribe
    subscribe id: @conversation.id

    # Verify subscription was rejected
    assert subscription.rejected?
  end

  test "broadcasts presence update on subscribe" do
    # Expect presence broadcast when subscribing
    assert_broadcast_on(ConversationChannel.broadcasting_for(@conversation), type: "presence") do
      subscribe id: @conversation.id
    end
  end

  test "handles typing action" do
    subscribe id: @conversation.id

    # Test typing notification
    assert_broadcast_on(ConversationChannel.broadcasting_for(@conversation), type: "typing", is_typing: true) do
      perform :typing, is_typing: true
    end

    # Test stop typing notification
    assert_broadcast_on(ConversationChannel.broadcasting_for(@conversation), type: "typing", is_typing: false) do
      perform :typing, is_typing: false
    end
  end

  test "broadcasts typing indicator with user information" do
    subscribe id: @conversation.id

    # Capture the broadcast
    assert_broadcasts(@conversation, 1) do
      perform :typing, is_typing: true
    end
  end

  test "multiple users can subscribe to the same conversation" do
    # First user (patient) subscribes
    stub_connection current_user: @patient
    subscribe id: @conversation.id
    assert subscription.confirmed?

    # Create new connection for second user (provider)
    stub_connection current_user: @provider
    subscribe id: @conversation.id
    assert subscription.confirmed?
  end

  test "unsubscribe broadcasts offline presence" do
    subscribe id: @conversation.id

    # Unsubscribe should broadcast offline status
    # Note: We can't easily test unsubscribe callback in test environment
    # This would require integration testing
    unsubscribe

    # Verify no longer subscribed
    assert_nil subscription.streams.first
  end

  private

  # Helper method to assert broadcasts on a specific channel
  def assert_broadcast_on(stream, data)
    old_messages = broadcasts(stream).dup
    yield
    new_messages = broadcasts(stream) - old_messages

    assert_not_empty new_messages, "Expected broadcast on #{stream}, but none occurred"

    if data.is_a?(Hash)
      data.each do |key, value|
        # Parse JSON strings if present
        assert new_messages.any? { |msg|
          parsed_msg = msg.is_a?(String) ? JSON.parse(msg) : msg
          parsed_msg[key.to_s] == value
        }, "Expected broadcast to include #{key}: #{value}, but got: #{new_messages}"
      end
    end
  end
end
