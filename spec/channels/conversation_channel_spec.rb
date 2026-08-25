require "rails_helper"

RSpec.describe ConversationChannel, type: :channel do
  let(:user) { create(:user) }
  let(:conversation) { create(:conversation, user: user) }

  it "subscribes to the conversation stream" do
    stub_connection(current_user: user)
    subscribe(conversation_id: conversation.id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("conversation_#{conversation.id}")
  end

  it "rejects when conversation belongs to another user" do
    other_user = create(:user)
    other_conversation = create(:conversation, user: other_user)

    stub_connection(current_user: user)
    subscribe(conversation_id: other_conversation.id)
    expect(subscription).to be_rejected
  end
end
