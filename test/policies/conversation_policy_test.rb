# frozen_string_literal: true

require "test_helper"

class ConversationPolicyTest < ActiveSupport::TestCase
  def setup
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @admin = users(:admin_user)
    @other_patient = users(:patient_user_two)

    @conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      last_message_at: 1.hour.ago
    )
  end

  # Scope tests
  test "scope returns user's conversations for patient" do
    scope = Pundit.policy_scope(@patient, Conversation)

    assert_includes scope, @conversation
    assert_equal @patient, @conversation.patient
  end

  test "scope returns user's conversations for provider" do
    scope = Pundit.policy_scope(@provider, Conversation)

    assert_includes scope, @conversation
    assert_equal @provider, @conversation.provider
  end

  test "scope returns all conversations for admin" do
    scope = Pundit.policy_scope(@admin, Conversation)

    # Admin should see all conversations
    assert_includes scope, @conversation
  end

  test "scope does not return other users' conversations" do
    scope = Pundit.policy_scope(@other_patient, Conversation)

    assert_not_includes scope, @conversation
  end

  # Index action tests
  test "patient can access index action" do
    policy = ConversationPolicy.new(@patient, Conversation)
    assert policy.index?
  end

  test "provider can access index action" do
    policy = ConversationPolicy.new(@provider, Conversation)
    assert policy.index?
  end

  test "admin can access index action" do
    policy = ConversationPolicy.new(@admin, Conversation)
    assert policy.index?
  end

  # Show action tests
  test "patient can view their own conversation" do
    policy = ConversationPolicy.new(@patient, @conversation)
    assert policy.show?
  end

  test "provider can view their own conversation" do
    policy = ConversationPolicy.new(@provider, @conversation)
    assert policy.show?
  end

  test "admin can view any conversation" do
    policy = ConversationPolicy.new(@admin, @conversation)
    assert policy.show?
  end

  test "user cannot view conversation they don't participate in" do
    policy = ConversationPolicy.new(@other_patient, @conversation)
    assert_not policy.show?
  end

  # Create action tests
  test "patient can create conversation where they are the patient" do
    new_conversation = Conversation.new(
      patient: @patient,
      provider: users(:provider_user_two)
    )
    policy = ConversationPolicy.new(@patient, new_conversation)
    assert policy.create?
  end

  test "provider can create conversation where they are the provider" do
    new_conversation = Conversation.new(
      patient: @other_patient,
      provider: @provider
    )
    policy = ConversationPolicy.new(@provider, new_conversation)
    assert policy.create?
  end

  test "admin can create any conversation" do
    new_conversation = Conversation.new(
      patient: @other_patient,
      provider: users(:provider_user_two)
    )
    policy = ConversationPolicy.new(@admin, new_conversation)
    assert policy.create?
  end

  test "user cannot create conversation they won't participate in" do
    new_conversation = Conversation.new(
      patient: @other_patient,
      provider: users(:provider_user_two)
    )
    policy = ConversationPolicy.new(@patient, new_conversation)
    assert_not policy.create?
  end

  test "cannot create conversation without patient" do
    new_conversation = Conversation.new(
      patient: nil,
      provider: @provider
    )
    policy = ConversationPolicy.new(@provider, new_conversation)
    assert_not policy.create?
  end

  test "cannot create conversation without provider" do
    new_conversation = Conversation.new(
      patient: @patient,
      provider: nil
    )
    policy = ConversationPolicy.new(@patient, new_conversation)
    assert_not policy.create?
  end

  # Update action tests
  test "patient cannot update conversation" do
    policy = ConversationPolicy.new(@patient, @conversation)
    assert_not policy.update?
  end

  test "provider cannot update conversation" do
    policy = ConversationPolicy.new(@provider, @conversation)
    assert_not policy.update?
  end

  test "admin can update conversation" do
    policy = ConversationPolicy.new(@admin, @conversation)
    assert policy.update?
  end

  # Destroy action tests
  test "patient cannot destroy conversation" do
    policy = ConversationPolicy.new(@patient, @conversation)
    assert_not policy.destroy?
  end

  test "provider cannot destroy conversation" do
    policy = ConversationPolicy.new(@provider, @conversation)
    assert_not policy.destroy?
  end

  test "admin can destroy conversation" do
    policy = ConversationPolicy.new(@admin, @conversation)
    assert policy.destroy?
  end

  # Archive action tests
  test "patient can archive their own conversation" do
    policy = ConversationPolicy.new(@patient, @conversation)
    assert policy.archive?
  end

  test "provider can archive their own conversation" do
    policy = ConversationPolicy.new(@provider, @conversation)
    assert policy.archive?
  end

  test "admin can archive any conversation" do
    policy = ConversationPolicy.new(@admin, @conversation)
    assert policy.archive?
  end

  test "user cannot archive conversation they don't participate in" do
    policy = ConversationPolicy.new(@other_patient, @conversation)
    assert_not policy.archive?
  end

  # Unarchive action tests
  test "patient can unarchive their own conversation" do
    @conversation.update(archived_by_patient: true)
    policy = ConversationPolicy.new(@patient, @conversation)
    assert policy.unarchive?
  end

  test "provider can unarchive their own conversation" do
    @conversation.update(archived_by_provider: true)
    policy = ConversationPolicy.new(@provider, @conversation)
    assert policy.unarchive?
  end

  test "admin can unarchive any conversation" do
    policy = ConversationPolicy.new(@admin, @conversation)
    assert policy.unarchive?
  end

  test "user cannot unarchive conversation they don't participate in" do
    policy = ConversationPolicy.new(@other_patient, @conversation)
    assert_not policy.unarchive?
  end

  # Mark as read action tests
  test "patient can mark their conversation as read" do
    policy = ConversationPolicy.new(@patient, @conversation)
    assert policy.mark_as_read?
  end

  test "provider can mark their conversation as read" do
    policy = ConversationPolicy.new(@provider, @conversation)
    assert policy.mark_as_read?
  end

  test "admin can mark any conversation as read" do
    policy = ConversationPolicy.new(@admin, @conversation)
    assert policy.mark_as_read?
  end

  test "user cannot mark as read conversation they don't participate in" do
    policy = ConversationPolicy.new(@other_patient, @conversation)
    assert_not policy.mark_as_read?
  end
end
