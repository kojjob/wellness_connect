# frozen_string_literal: true

# Controller for managing conversations between patients and providers
#
# Actions:
# - index: List all conversations for current user (filtered by role)
# - show: Display conversation thread with messages
# - create: Start new conversation (for general messaging)
#
class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show, :archive, :unarchive ]

  # GET /conversations
  # List all conversations for current user, ordered by most recent activity
  def index
    authorize Conversation
    @conversations = policy_scope(Conversation)
                      .includes(:patient, :provider, :appointment)
                      .recent
                      .page(params[:page])
                      .per(20)

    # Separate unarchived and archived conversations
    @active_conversations = @conversations.unarchived_for(current_user)
    @archived_conversations = @conversations.archived_for(current_user)
  end

  # GET /conversations/:id
  # Display conversation thread with messages and mark as read
  def show
    authorize @conversation

    # Load messages in chronological order with sender information
    @messages = @conversation.messages
                             .includes(:sender)
                             .ordered
                             .page(params[:page])
                             .per(50)

    # Mark messages as read for current user (non-sender messages only)
    mark_conversation_as_read

    # Build new message for form
    @new_message = @conversation.messages.build(sender: current_user)
  end

  # POST /conversations
  # Create new conversation (for general messaging, not appointment-based)
  def create
    @conversation = Conversation.new(conversation_params)
    @conversation.patient_id ||= current_user.id if current_user.patient?
    @conversation.provider_id ||= current_user.id if current_user.provider?

    authorize @conversation

    if @conversation.save
      redirect_to @conversation, notice: "Conversation started successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /conversations/:id/archive
  # Archive conversation for current user
  def archive
    authorize @conversation

    if current_user.patient? && @conversation.patient_id == current_user.id
      @conversation.update(patient_archived: true)
    elsif current_user.provider? && @conversation.provider_id == current_user.id
      @conversation.update(provider_archived: true)
    end

    redirect_to conversations_path, notice: "Conversation archived."
  end

  # PATCH /conversations/:id/unarchive
  # Unarchive conversation for current user
  def unarchive
    authorize @conversation

    if current_user.patient? && @conversation.patient_id == current_user.id
      @conversation.update(patient_archived: false)
    elsif current_user.provider? && @conversation.provider_id == current_user.id
      @conversation.update(provider_archived: false)
    end

    redirect_to conversations_path, notice: "Conversation unarchived."
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:patient_id, :provider_id, :appointment_id)
  end

  # Mark unread messages as read for current user
  def mark_conversation_as_read
    if current_user.patient? && @conversation.patient_id == current_user.id
      @conversation.mark_as_read_for_patient
    elsif current_user.provider? && @conversation.provider_id == current_user.id
      @conversation.mark_as_read_for_provider
    end
  end
end
