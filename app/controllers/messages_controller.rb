class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = current_user.conversations.find(params[:conversation_id])
    @message = @conversation.messages.build(role: "user", content: params[:message][:content])

    if @message.save
      ai_response(@conversation)
      redirect_to @conversation
    else
      redirect_to @conversation, alert: "Message could not be saved."
    end
  end

  private

  def ai_response(conversation)
    messages = [{ role: "system", content: "You are a helpful AI writing assistant. Be concise and helpful." }]
    messages += conversation.history

    ai = AiService.new
    response = ai.chat(messages)

    conversation.messages.create!(role: "assistant", content: response)
  end
end
