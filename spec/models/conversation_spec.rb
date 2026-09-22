require "rails_helper"

RSpec.describe Conversation, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:messages).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:title) }

  describe "#history" do
    it "maps messages to role/content hashes ordered by creation" do
      conversation = create(:conversation, user: create(:user), title: "Draft")
      older = create(:message, conversation: conversation, role: "user", content: "first", created_at: 1.hour.ago)
      newer = create(:message, conversation: conversation, role: "assistant", content: "second")

      expect(conversation.history).to eq(
        [
          { role: older.role, content: older.content },
          { role: newer.role, content: newer.content }
        ]
      )
    end
  end
end
