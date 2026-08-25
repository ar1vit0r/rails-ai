class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])
    if conversation.user_id == current_user.id
      stream_from "conversation_#{conversation.id}"
    else
      reject
    end
  end

  def unsubscribed
  end
end
