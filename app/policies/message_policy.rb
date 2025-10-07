# frozen_string_literal: true

# Policy class for authorizing Message actions
#
# Authorization Rules:
# - Only conversation participants can create messages
# - Only the sender can edit their own message (within edit window)
# - Only the sender or admin can delete a message
# - Participants can view messages in their conversations
# - Marking as read requires being the recipient (non-sender participant)
#
class MessagePolicy < ApplicationPolicy
  # Scope for fetching messages accessible to current user
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        # Admins can see all messages
        scope.all
      else
        # Users can see messages from conversations they participate in
        scope.joins(:conversation)
             .where("conversations.patient_id = ? OR conversations.provider_id = ?", user.id, user.id)
      end
    end
  end

  # Index action - users can view messages if they're conversation participants
  def index?
    conversation_participant?
  end

  # Show action - users can view message if they're conversation participants
  def show?
    conversation_participant?
  end

  # Create action - only conversation participants can create messages
  def create?
    conversation_participant?
  end

  # Update action - only sender can edit their own message (model enforces time limit)
  def update?
    user.admin? || sender?
  end

  # Destroy action - only sender or admin can delete message
  def destroy?
    user.admin? || sender?
  end

  # Mark as read action - only recipient (non-sender participant) can mark as read
  def mark_as_read?
    conversation_participant? && !sender?
  end

  # Download attachment action - conversation participants can download attachments
  def download_attachment?
    conversation_participant?
  end

  private

  # Check if current user is a participant in the message's conversation
  def conversation_participant?
    return false unless record.conversation.present?

    user.admin? ||
      record.conversation.patient_id == user.id ||
      record.conversation.provider_id == user.id
  end

  # Check if current user is the sender of the message
  def sender?
    record.sender_id == user.id
  end
end
