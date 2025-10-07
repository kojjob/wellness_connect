class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:id])

    # Authorize: User must be a participant in the conversation
    if conversation.participant?(current_user)
      stream_for conversation

      # Broadcast presence (user came online)
      broadcast_presence_update(conversation, "online")
    else
      reject
    end
  end

  def unsubscribed
    # Broadcast presence (user went offline)
    conversation = Conversation.find_by(id: params[:id])
    broadcast_presence_update(conversation, "offline") if conversation
  end

  def typing(data)
    # Broadcast typing indicator to other participant
    conversation = Conversation.find(params[:id])

    ConversationChannel.broadcast_to(
      conversation,
      type: "typing",
      user_id: current_user.id,
      user_name: current_user.full_name,
      is_typing: data["is_typing"]
    )
  end

  private

  def broadcast_presence_update(conversation, status)
    ConversationChannel.broadcast_to(
      conversation,
      type: "presence",
      user_id: current_user.id,
      user_name: current_user.full_name,
      status: status
    )
  end
end
