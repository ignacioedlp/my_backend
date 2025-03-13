require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include Devise::Test::ControllerHelpers
  include FactoryBot::Syntax::Methods

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:banned_user) { create(:user, :banned) }

  let(:token) { admin.generate_jwt_token }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET #index" do
    context "when authenticated as admin" do
      before { sign_in admin }

      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end
    end

    context "when not authenticated" do
      it "returns unauthorized" do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #show" do
    context "when authenticated as admin" do
      before { sign_in admin }

      it "returns a success response for existing user" do
        get :show, params: { id: user.id }
        expect(response).to be_successful
      end

      it "returns 404 for non-existent user" do
        get :show, params: { id: 0 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #ban" do
    context "when admin bans a user" do
      before { sign_in admin }

      it "allows admin to suspend a user" do
        post :ban, params: { id: user.id, reason: "Violation" }
        expect(response).to be_successful
        expect(JSON.parse(response.body)["message"]).to eq("User successfully suspended.")
      end

      it "returns 404 for non-existent user" do
        post :ban, params: { id: 0, reason: "Violation" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when a user tries to ban another user" do
      before { sign_in user }

      it "forbids the action" do
        post :ban, params: { id: admin.id, reason: "Violation" }
        expect(response).to have_http_status(:forbidden)
      end

      it "does not allow a user to ban themselves" do
        post :ban, params: { id: user.id, reason: "Violation" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST #unban" do
    context "when admin unbans a user" do
      before { sign_in admin }

      it "allows admin to unban a user" do
        post :unban, params: { id: banned_user.id }
        expect(response).to be_successful
        expect(JSON.parse(response.body)["message"]).to eq("User suspension has been lifted.")
      end

      it "returns 404 for non-existent user" do
        post :unban, params: { id: 0 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when a user tries to unban another user" do
      before { sign_in user }

      it "forbids the action" do
        post :unban, params: { id: banned_user.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when admin deletes a user" do
      before { sign_in admin }

      it "destroys the requested user" do
        expect {
          delete :destroy, params: { id: user.id }
        }.to change(User, :count).by(0)
      end

      it "returns 404 for non-existent user" do
        delete :destroy, params: { id: 0 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
