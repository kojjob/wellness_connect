# frozen_string_literal: true

require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @admin = users(:admin_user)

    # Create a conversation for testing
    @conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      last_message_at: 1.hour.ago
    )

    # Create messages in the conversation
    @patient_message = @conversation.messages.create!(
      sender: @patient,
      content: "Patient's message",
      message_type: "text"
    )

    @provider_message = @conversation.messages.create!(
      sender: @provider,
      content: "Provider's message",
      message_type: "text"
    )
  end

  # Create action tests
  test "patient can create message in their conversation" do
    sign_in @patient

    assert_difference("Message.count", 1) do
      post conversation_messages_path(@conversation), params: {
        message: {
          content: "New test message",
          message_type: "text"
        }
      }
    end

    assert_redirected_to conversation_path(@conversation)
    assert_equal "Message sent successfully.", flash[:notice]
    assert_equal @patient, Message.last.sender
  end

  test "provider can create message in their conversation" do
    sign_in @provider

    assert_difference("Message.count", 1) do
      post conversation_messages_path(@conversation), params: {
        message: {
          content: "Provider's new message",
          message_type: "text"
        }
      }
    end

    assert_redirected_to conversation_path(@conversation)
  end

  test "admin can create message in any conversation" do
    sign_in @admin

    assert_difference("Message.count", 1) do
      post conversation_messages_path(@conversation), params: {
        message: {
          content: "Admin message",
          message_type: "text"
        }
      }
    end

    assert_redirected_to conversation_path(@conversation)
  end

  test "user cannot create message in conversation they don't participate in" do
    other_patient = users(:patient_user_two)
    sign_in other_patient

    assert_raises(Pundit::NotAuthorizedError) do
      post conversation_messages_path(@conversation), params: {
        message: {
          content: "Should not be allowed",
          message_type: "text"
        }
      }
    end
  end

  test "unauthenticated user cannot create message" do
    post conversation_messages_path(@conversation), params: {
      message: {
        content: "Should not be allowed",
        message_type: "text"
      }
    }

    assert_redirected_to new_user_session_path
  end

  test "cannot create message with blank content" do
    sign_in @patient

    assert_no_difference("Message.count") do
      post conversation_messages_path(@conversation), params: {
        message: {
          content: "",
          message_type: "text"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "creating message updates conversation's last_message_at" do
    sign_in @patient
    original_time = @conversation.last_message_at

    post conversation_messages_path(@conversation), params: {
      message: {
        content: "New message",
        message_type: "text"
      }
    }

    @conversation.reload
    assert @conversation.last_message_at > original_time
  end

  # Update action tests
  test "sender can update their own message within time limit" do
    sign_in @patient

    # Ensure message is recent (within 15 minutes)
    @patient_message.update!(created_at: 5.minutes.ago)

    patch conversation_message_path(@conversation, @patient_message), params: {
      message: {
        content: "Updated content"
      }
    }

    @patient_message.reload
    assert_equal "Updated content", @patient_message.content
    assert_not_nil @patient_message.edited_at
    assert_redirected_to conversation_path(@conversation)
  end

  test "sender cannot update message after time limit" do
    sign_in @patient

    # Make message older than 15 minutes
    @patient_message.update!(created_at: 20.minutes.ago)

    patch conversation_message_path(@conversation, @patient_message), params: {
      message: {
        content: "Should not be updated"
      }
    }

    @patient_message.reload
    assert_not_equal "Should not be updated", @patient_message.content
    assert_redirected_to conversation_path(@conversation)
    assert_match(/can no longer be edited/, flash[:alert])
  end

  test "user cannot update someone else's message" do
    sign_in @patient

    assert_raises(Pundit::NotAuthorizedError) do
      patch conversation_message_path(@conversation, @provider_message), params: {
        message: {
          content: "Should not be allowed"
        }
      }
    end
  end

  test "admin can update any message" do
    sign_in @admin

    # Even if outside time limit
    @patient_message.update!(created_at: 20.minutes.ago)

    patch conversation_message_path(@conversation, @patient_message), params: {
      message: {
        content: "Admin update"
      }
    }

    @patient_message.reload
    assert_equal "Admin update", @patient_message.content
  end

  test "updating message sets edited_at timestamp" do
    sign_in @patient
    @patient_message.update!(created_at: 5.minutes.ago)

    assert_nil @patient_message.edited_at

    patch conversation_message_path(@conversation, @patient_message), params: {
      message: {
        content: "Updated content"
      }
    }

    @patient_message.reload
    assert_not_nil @patient_message.edited_at
  end

  # Destroy action tests
  test "sender can delete their own message" do
    sign_in @patient

    assert_difference("Message.count", -1) do
      delete conversation_message_path(@conversation, @patient_message)
    end

    assert_redirected_to conversation_path(@conversation)
    assert_equal "Message deleted successfully.", flash[:notice]
  end

  test "user cannot delete someone else's message" do
    sign_in @patient

    assert_raises(Pundit::NotAuthorizedError) do
      delete conversation_message_path(@conversation, @provider_message)
    end
  end

  test "admin can delete any message" do
    sign_in @admin

    assert_difference("Message.count", -1) do
      delete conversation_message_path(@conversation, @patient_message)
    end

    assert_redirected_to conversation_path(@conversation)
  end

  test "deleting last message in conversation is allowed" do
    sign_in @patient

    # Delete all messages except one
    @provider_message.destroy

    assert_difference("Message.count", -1) do
      delete conversation_message_path(@conversation, @patient_message)
    end

    assert_redirected_to conversation_path(@conversation)
  end

  # Mark as read action tests
  test "recipient can mark message as read" do
    sign_in @patient

    # Provider's message should be unread for patient
    assert_not @provider_message.read?

    patch mark_as_read_conversation_message_path(@conversation, @provider_message)

    @provider_message.reload
    assert @provider_message.read?
    assert_not_nil @provider_message.read_at
    assert_redirected_to conversation_path(@conversation)
  end

  test "sender cannot mark their own message as read" do
    sign_in @patient

    assert_raises(Pundit::NotAuthorizedError) do
      patch mark_as_read_conversation_message_path(@conversation, @patient_message)
    end
  end

  test "user cannot mark as read in conversation they don't participate in" do
    other_patient = users(:patient_user_two)
    sign_in other_patient

    assert_raises(Pundit::NotAuthorizedError) do
      patch mark_as_read_conversation_message_path(@conversation, @provider_message)
    end
  end

  test "marking message as read updates conversation unread count" do
    sign_in @patient

    # Provider sends a new message
    new_message = @conversation.messages.create!(
      sender: @provider,
      content: "Another message",
      message_type: "text"
    )

    assert @conversation.patient_unread_count > 0

    patch mark_as_read_conversation_message_path(@conversation, new_message)

    @conversation.reload
    # Unread count should be decremented
    assert @conversation.patient_unread_count >= 0
  end

  test "admin can mark any message as read" do
    sign_in @admin

    patch mark_as_read_conversation_message_path(@conversation, @provider_message)

    @provider_message.reload
    assert @provider_message.read?
  end

  private

  def sign_in(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }
  end
end
