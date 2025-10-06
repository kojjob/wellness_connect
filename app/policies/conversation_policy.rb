# frozen_string_literal: true

# Policy class for authorizing Conversation actions
#
# Authorization Rules:
# - Clients can view their own conversations (as patient)
# - Providers can view their own conversations (as provider)
# - Admins can view all conversations
# - Users can only create conversations they will participate in
# - Only participants can update/delete conversations
#
class ConversationPolicy < ApplicationPolicy
  # Scope for fetching conversations accessible to current user
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        # Admins can see all conversations
        scope.all
      elsif user.provider?
        # Providers see conversations where they are the provider
        scope.where(provider_id: user.id)
      else
        # Clients see conversations where they are the patient
        scope.where(patient_id: user.id)
      end
    end
  end

  # Index action - users can view list of their conversations
  def index?
    true # Scope handles filtering
  end

  # Show action - users can view conversation if they're a participant
  def show?
    participant?
  end

  # Create action - users can create conversations they will participate in
  def create?
    # For appointment-specific conversations, user must be either the patient or provider
    # For general conversations, user must be one of the participants
    return false unless record.patient_id.present? && record.provider_id.present?

    user.admin? || record.patient_id == user.id || record.provider_id == user.id
  end

  # Update action - only admins can update conversations (for moderation)
  def update?
    user.admin?
  end

  # Destroy action - only admins can delete conversations (for moderation)
  def destroy?
    user.admin?
  end

  # Archive action - participants can archive their own view of conversation
  def archive?
    participant?
  end

  # Unarchive action - participants can unarchive their own view
  def unarchive?
    participant?
  end

  # Mark as read action - participants can mark messages as read
  def mark_as_read?
    participant?
  end

  private

  # Check if current user is a participant in the conversation
  def participant?
    user.admin? || record.patient_id == user.id || record.provider_id == user.id
  end
end
