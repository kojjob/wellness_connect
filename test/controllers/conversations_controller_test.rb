# frozen_string_literal: true

require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @admin = users(:admin_user)

    # Create conversations for testing
    @patient_conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      last_message_at: 1.hour.ago
    )

    @other_patient = users(:patient_user_two)
    @other_conversation = Conversation.create!(
      patient: @other_patient,
      provider: @provider,
      last_message_at: 2.hours.ago
    )
  end

  # Index action tests
  test "patient can view their own conversations" do
    sign_in @patient

    get conversations_path
    assert_response :success
    assert_select "h1", text: "Messages"
  end

  test "provider can view their conversations" do
    sign_in @provider

    get conversations_path
    assert_response :success
    assert_select "h1", text: "Messages"
  end

  test "admin can view all conversations" do
    sign_in @admin

    get conversations_path
    assert_response :success
  end

  test "unauthenticated user cannot view conversations" do
    get conversations_path
    assert_redirected_to new_user_session_path
  end

  test "patient only sees conversations they participate in" do
    sign_in @patient

    get conversations_path
    assert_response :success

    # Should see their conversation
    assert_match @provider.full_name, response.body

    # Should not see other patient's conversation details
    assert_no_match @other_patient.full_name, response.body
  end

  # Show action tests
  test "patient can view their own conversation" do
    sign_in @patient

    get conversation_path(@patient_conversation)
    assert_response :success
    assert_select "h1", text: @provider.full_name
  end

  test "provider can view their conversation" do
    sign_in @provider

    get conversation_path(@patient_conversation)
    assert_response :success
    assert_select "h1", text: @patient.full_name
  end

  test "admin can view any conversation" do
    sign_in @admin

    get conversation_path(@patient_conversation)
    assert_response :success
  end

  test "patient cannot view conversation they don't participate in" do
    sign_in @patient

    assert_raises(Pundit::NotAuthorizedError) do
      get conversation_path(@other_conversation)
    end
  end

  test "show action marks conversation as read for patient" do
    # Create unread messages
    message = @patient_conversation.messages.create!(
      sender: @provider,
      content: "Test message"
    )

    assert_equal 1, @patient_conversation.patient_unread_count

    sign_in @patient
    get conversation_path(@patient_conversation)

    @patient_conversation.reload
    assert_equal 0, @patient_conversation.patient_unread_count
  end

  test "show action marks conversation as read for provider" do
    # Create unread messages
    message = @patient_conversation.messages.create!(
      sender: @patient,
      content: "Test message"
    )

    assert_equal 1, @patient_conversation.provider_unread_count

    sign_in @provider
    get conversation_path(@patient_conversation)

    @patient_conversation.reload
    assert_equal 0, @patient_conversation.provider_unread_count
  end

  # Create action tests
  test "user can create conversation with valid params" do
    sign_in @patient

    other_provider = users(:provider_user_two)

    assert_difference("Conversation.count", 1) do
      post conversations_path, params: {
        conversation: {
          patient_id: @patient.id,
          provider_id: other_provider.id
        }
      }
    end

    assert_redirected_to conversation_path(Conversation.last)
  end

  test "user cannot create conversation with invalid params" do
    sign_in @patient

    assert_no_difference("Conversation.count") do
      post conversations_path, params: {
        conversation: {
          patient_id: nil,
          provider_id: nil
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "user cannot create conversation they won't participate in" do
    sign_in @patient

    other_patient = users(:patient_user_two)
    other_provider = users(:provider_user_two)

    assert_raises(Pundit::NotAuthorizedError) do
      post conversations_path, params: {
        conversation: {
          patient_id: other_patient.id,
          provider_id: other_provider.id
        }
      }
    end
  end

  # Archive action tests
  test "patient can archive their own conversation" do
    sign_in @patient

    assert_not @patient_conversation.patient_archived

    patch archive_conversation_path(@patient_conversation)
    assert_redirected_to conversations_path

    @patient_conversation.reload
    assert @patient_conversation.patient_archived
    assert_not @patient_conversation.provider_archived
  end

  test "provider can archive their own conversation" do
    sign_in @provider

    assert_not @patient_conversation.provider_archived

    patch archive_conversation_path(@patient_conversation)
    assert_redirected_to conversations_path

    @patient_conversation.reload
    assert @patient_conversation.provider_archived
    assert_not @patient_conversation.patient_archived
  end

  test "user cannot archive conversation they don't participate in" do
    sign_in @patient

    assert_raises(Pundit::NotAuthorizedError) do
      patch archive_conversation_path(@other_conversation)
    end
  end

  # Unarchive action tests
  test "patient can unarchive their archived conversation" do
    @patient_conversation.update(patient_archived: true)
    sign_in @patient

    patch unarchive_conversation_path(@patient_conversation)
    assert_redirected_to conversations_path

    @patient_conversation.reload
    assert_not @patient_conversation.patient_archived
  end

  test "provider can unarchive their archived conversation" do
    @patient_conversation.update(provider_archived: true)
    sign_in @provider

    patch unarchive_conversation_path(@patient_conversation)
    assert_redirected_to conversations_path

    @patient_conversation.reload
    assert_not @patient_conversation.provider_archived
  end

  test "user cannot unarchive conversation they don't participate in" do
    sign_in @patient

    assert_raises(Pundit::NotAuthorizedError) do
      patch unarchive_conversation_path(@other_conversation)
    end
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
