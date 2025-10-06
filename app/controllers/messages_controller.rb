# frozen_string_literal: true

# Controller for managing messages within conversations
#
# Messages are nested under conversations:
# - POST /conversations/:conversation_id/messages - Create new message
# - PATCH /conversations/:conversation_id/messages/:id - Edit message (within time limit)
# - DELETE /conversations/:conversation_id/messages/:id - Delete message
#
# Uses Turbo Streams for real-time message updates
#
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :set_message, only: [ :update, :destroy, :mark_as_read ]

  # POST /conversations/:conversation_id/messages
  # Create new message and broadcast via Turbo Stream
  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user

    authorize @message

    respond_to do |format|
      if @message.save
        # Broadcast message via Turbo Stream for real-time updates
        # Both participants will see the new message
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "conversation_messages",
            partial: "messages/message",
            locals: { message: @message, current_user: current_user }
          )
        end

        format.html do
          redirect_to conversation_path(@conversation), notice: "Message sent successfully."
        end

        format.json { render json: @message, status: :created }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "messages/form",
            locals: { conversation: @conversation, message: @message }
          )
        end

        format.html do
          @messages = @conversation.messages.includes(:sender).ordered
          render "conversations/show", status: :unprocessable_entity
        end

        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /conversations/:conversation_id/messages/:id
  # Update message content (only within edit time window)
  def update
    authorize @message

    # Check if message is still editable (model validation handles time limit)
    unless @message.editable?
      redirect_to conversation_path(@conversation),
                  alert: "Message can no longer be edited (15 minute limit exceeded)."
      return
    end

    respond_to do |format|
      if @message.update(message_update_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_#{@message.id}",
            partial: "messages/message",
            locals: { message: @message, current_user: current_user }
          )
        end

        format.html do
          redirect_to conversation_path(@conversation), notice: "Message updated successfully."
        end

        format.json { render json: @message }
      else
        format.html do
          redirect_to conversation_path(@conversation), alert: @message.errors.full_messages.join(", ")
        end

        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conversations/:conversation_id/messages/:id
  # Delete message (soft delete or hard delete based on requirements)
  def destroy
    authorize @message

    respond_to do |format|
      if @message.destroy
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("message_#{@message.id}")
        end

        format.html do
          redirect_to conversation_path(@conversation), notice: "Message deleted successfully."
        end

        format.json { head :no_content }
      else
        format.html do
          redirect_to conversation_path(@conversation), alert: "Failed to delete message."
        end

        format.json { render json: { error: "Failed to delete message" }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /conversations/:conversation_id/messages/:id/mark_as_read
  # Mark message as read by recipient
  def mark_as_read
    authorize @message

    @message.mark_as_read

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "message_#{@message.id}",
          partial: "messages/message",
          locals: { message: @message, current_user: current_user }
        )
      end

      format.html { redirect_to conversation_path(@conversation) }
      format.json { render json: @message }
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
    authorize @conversation, :show?
  rescue Pundit::NotAuthorizedError
    redirect_to conversations_path, alert: "You are not authorized to access this conversation."
  end

  def set_message
    @message = @conversation.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, :message_type)
  end

  def message_update_params
    params.require(:message).permit(:content)
  end
end
