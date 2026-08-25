require "rails_helper"

RSpec.describe "Messages", type: :request do
  let(:user) { create(:user) }
  let(:conversation) { create(:conversation, user: user) }

  describe "POST /conversations/:conversation_id/messages" do
    context "when logged in" do
      before { sign_in user }

      it "creates user and assistant messages and returns ok" do
        expect {
          post conversation_messages_path(conversation), params: { message: { content: "Hello AI" } }
        }.to change(Message, :count).by(2)
        expect(response).to have_http_status(:ok)
        expect(Message.where(role: "user").last.content).to eq("Hello AI")
        expect(Message.where(role: "assistant").last.content).not_to be_blank
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        post conversation_messages_path(conversation), params: { message: { content: "Hello" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when message is empty" do
      before { sign_in user }

      it "returns unprocessable entity" do
        post conversation_messages_path(conversation), params: { message: { content: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
