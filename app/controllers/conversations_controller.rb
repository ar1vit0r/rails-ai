class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = current_user.conversations.order(updated_at: :desc).load
    @message_counts = Message.where(conversation_id: @conversations.map(&:id)).group(:conversation_id).count
  end

  def show
    @conversation = current_user.conversations.find(params[:id])
    @messages = @conversation.messages.order(:created_at)
    @message = Message.new
  end

  def create
    @conversation = current_user.conversations.build(title: params[:title] || "New Conversation")
    if @conversation.save
      redirect_to @conversation
    else
      redirect_to conversations_path, alert: "Could not create conversation."
    end
  end

  def destroy
    @conversation = current_user.conversations.find(params[:id])
    @conversation.destroy
    redirect_to conversations_path, notice: "Conversation deleted."
  end
end
