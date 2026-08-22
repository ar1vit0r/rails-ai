require "rails_helper"

RSpec.describe "Conversations", type: :request do
  let(:user) { create(:user) }

  describe "GET /conversations" do
    context "when logged in" do
      before { sign_in user }

      it "returns http success" do
        get conversations_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get conversations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /conversations" do
    context "when logged in" do
      before { sign_in user }

      it "creates a conversation" do
        expect {
          post conversations_path, params: { title: "Test Chat" }
        }.to change(Conversation, :count).by(1)
        expect(response).to redirect_to(conversation_path(Conversation.last))
      end
    end
  end
end
