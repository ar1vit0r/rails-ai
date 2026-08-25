class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = current_user.conversations.find(params[:conversation_id])
    @message = @conversation.messages.build(role: "user", content: params[:message][:content])

    if @message.save
      broadcast_user_message(@conversation, @message)
      stream_ai_response(@conversation)
      head :ok
    else
      render json: { error: "Message could not be saved." }, status: :unprocessable_entity
    end
  end

  private

  def broadcast_user_message(conversation, message)
    ActionCable.server.broadcast(
      "conversation_#{conversation.id}",
      {
        type: "user_message",
        html: render_message(message)
      }
    )
  rescue StandardError
    nil
  end

  def stream_ai_response(conversation)
    messages = [{ role: "system", content: "You are a helpful AI writing assistant. Be concise and helpful." }]
    messages += conversation.history

    ai = AiService.new
    ai_message = conversation.messages.create!(role: "assistant", content: "...")
    full_text = +""

    ActionCable.server.broadcast(
      "conversation_#{conversation.id}",
      { type: "ai_start", message_id: ai_message.id }
    )

    ai.stream_chat(messages) do |chunk, text|
      full_text = text
      ai_message.update_column(:content, full_text)

      ActionCable.server.broadcast(
        "conversation_#{conversation.id}",
        {
          type: "ai_chunk",
          message_id: ai_message.id,
          chunk: chunk,
          html: render_message(ai_message.reload)
        }
      )
    end

    ai_message.update_column(:content, full_text.presence || "...")

    ActionCable.server.broadcast(
      "conversation_#{conversation.id}",
      { type: "ai_done", message_id: ai_message.id }
    )
  rescue StandardError
    nil
  end

  def render_message(message)
    ApplicationController.renderer.render(
      partial: "messages/message",
      locals: { message: message }
    )
  end
end
