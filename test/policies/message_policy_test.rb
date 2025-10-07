# frozen_string_literal: true

require "test_helper"

class MessagePolicyTest < ActiveSupport::TestCase
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @admin = users(:admin_user)
    @other_patient = users(:patient_user_two)

    # Create a conversation between patient and provider
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

  # Scope tests
  test "admin can see all messages" do
    # Create another conversation and message
    other_conversation = Conversation.create!(
      patient: users(:patient_user_two),
      provider: users(:provider_user_two)
    )
    other_message = other_conversation.messages.create!(
      sender: users(:patient_user_two),
      content: "Other conversation message"
    )

    scope = MessagePolicy::Scope.new(@admin, Message.all).resolve

    # Admin should see all messages
    assert_includes scope, @patient_message
    assert_includes scope, @provider_message
    assert_includes scope, other_message
  end

  test "patient sees messages from their conversations only" do
    # Create another conversation that patient is NOT part of
    other_conversation = Conversation.create!(
      patient: users(:patient_user_two),
      provider: users(:provider_user_two)
    )
    other_message = other_conversation.messages.create!(
      sender: users(:patient_user_two),
      content: "Other conversation message"
    )

    scope = MessagePolicy::Scope.new(@patient, Message.all).resolve

    # Patient should see messages from their conversation
    assert_includes scope, @patient_message
    assert_includes scope, @provider_message

    # Patient should NOT see messages from other conversations
    assert_not_includes scope, other_message
  end

  test "provider sees messages from their conversations only" do
    # Create another conversation that provider is NOT part of
    other_conversation = Conversation.create!(
      patient: users(:patient_user_two),
      provider: users(:provider_user_two)
    )
    other_message = other_conversation.messages.create!(
      sender: users(:patient_user_two),
      content: "Other conversation message"
    )

    scope = MessagePolicy::Scope.new(@provider, Message.all).resolve

    # Provider should see messages from their conversation
    assert_includes scope, @patient_message
    assert_includes scope, @provider_message

    # Provider should NOT see messages from other conversations
    assert_not_includes scope, other_message
  end

  # show? tests
  test "conversation participant can view message" do
    patient_policy = MessagePolicy.new(@patient, @provider_message)
    assert patient_policy.show?

    provider_policy = MessagePolicy.new(@provider, @patient_message)
    assert provider_policy.show?
  end

  test "non-participant cannot view message" do
    policy = MessagePolicy.new(@other_patient, @patient_message)
    assert_not policy.show?
  end

  test "admin can view any message" do
    policy = MessagePolicy.new(@admin, @patient_message)
    assert policy.show?
  end

  # create? tests
  test "conversation participant can create message" do
    patient_policy = MessagePolicy.new(@patient, @patient_message)
    assert patient_policy.create?

    provider_policy = MessagePolicy.new(@provider, @provider_message)
    assert provider_policy.create?
  end

  test "non-participant cannot create message" do
    policy = MessagePolicy.new(@other_patient, @patient_message)
    assert_not policy.create?
  end

  test "admin can create message in any conversation" do
    policy = MessagePolicy.new(@admin, @patient_message)
    assert policy.create?
  end

  # update? tests
  test "sender can update their own message" do
    patient_policy = MessagePolicy.new(@patient, @patient_message)
    assert patient_policy.update?

    provider_policy = MessagePolicy.new(@provider, @provider_message)
    assert provider_policy.update?
  end

  test "sender cannot update someone else's message" do
    patient_policy = MessagePolicy.new(@patient, @provider_message)
    assert_not patient_policy.update?

    provider_policy = MessagePolicy.new(@provider, @patient_message)
    assert_not provider_policy.update?
  end

  test "admin can update any message" do
    patient_message_policy = MessagePolicy.new(@admin, @patient_message)
    assert patient_message_policy.update?

    provider_message_policy = MessagePolicy.new(@admin, @provider_message)
    assert provider_message_policy.update?
  end

  test "non-participant cannot update message" do
    policy = MessagePolicy.new(@other_patient, @patient_message)
    assert_not policy.update?
  end

  # destroy? tests
  test "sender can delete their own message" do
    patient_policy = MessagePolicy.new(@patient, @patient_message)
    assert patient_policy.destroy?

    provider_policy = MessagePolicy.new(@provider, @provider_message)
    assert provider_policy.destroy?
  end

  test "sender cannot delete someone else's message" do
    patient_policy = MessagePolicy.new(@patient, @provider_message)
    assert_not patient_policy.destroy?

    provider_policy = MessagePolicy.new(@provider, @patient_message)
    assert_not provider_policy.destroy?
  end

  test "admin can delete any message" do
    patient_message_policy = MessagePolicy.new(@admin, @patient_message)
    assert patient_message_policy.destroy?

    provider_message_policy = MessagePolicy.new(@admin, @provider_message)
    assert provider_message_policy.destroy?
  end

  test "non-participant cannot delete message" do
    policy = MessagePolicy.new(@other_patient, @patient_message)
    assert_not policy.destroy?
  end

  # mark_as_read? tests
  test "recipient can mark message as read" do
    # Patient is recipient of provider's message
    patient_policy = MessagePolicy.new(@patient, @provider_message)
    assert patient_policy.mark_as_read?

    # Provider is recipient of patient's message
    provider_policy = MessagePolicy.new(@provider, @patient_message)
    assert provider_policy.mark_as_read?
  end

  test "sender cannot mark their own message as read" do
    # Patient sent this message, cannot mark it as read
    patient_policy = MessagePolicy.new(@patient, @patient_message)
    assert_not patient_policy.mark_as_read?

    # Provider sent this message, cannot mark it as read
    provider_policy = MessagePolicy.new(@provider, @provider_message)
    assert_not provider_policy.mark_as_read?
  end

  test "admin can mark any message as read" do
    # Admin can mark any message as read for moderation purposes
    patient_message_policy = MessagePolicy.new(@admin, @patient_message)
    assert patient_message_policy.mark_as_read?

    provider_message_policy = MessagePolicy.new(@admin, @provider_message)
    assert provider_message_policy.mark_as_read?
  end

  test "non-participant cannot mark message as read" do
    policy = MessagePolicy.new(@other_patient, @patient_message)
    assert_not policy.mark_as_read?
  end

  # index? tests
  test "conversation participant can view message list" do
    patient_policy = MessagePolicy.new(@patient, @patient_message)
    assert patient_policy.index?

    provider_policy = MessagePolicy.new(@provider, @provider_message)
    assert provider_policy.index?
  end

  test "non-participant cannot view message list" do
    policy = MessagePolicy.new(@other_patient, @patient_message)
    assert_not policy.index?
  end

  test "admin can view any message list" do
    policy = MessagePolicy.new(@admin, @patient_message)
    assert policy.index?
  end
end
