require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:conversations).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }

  it "destroys associated conversations when destroyed" do
    user = create(:user)
    conversation = create(:conversation, user: user)

    expect { user.destroy }.to change(Conversation, :count).by(-1)
    expect(Conversation.exists?(conversation.id)).to be(false)
  end
end
