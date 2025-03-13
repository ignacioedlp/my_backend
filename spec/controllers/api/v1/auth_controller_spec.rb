require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :controller do
    include Devise::Test::ControllerHelpers
    include FactoryBot::Syntax::Methods # Asegúrate de que esté incluido también


    let(:user) { create(:user, confirmed_at: Time.current, password: 'password') }
    let(:unconfirmed_user) { create(:user, confirmed_at: nil, password: 'password') }
    let(:banned_user) { create(:user, banned: true, ban_reason: "Violation of terms") }

  describe 'POST #register' do
    it 'registers a new user successfully' do
      post :register, params: { email: 'test@example.com', password: 'password', password_confirmation: 'password' }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['message']).to eq('User registered successfully. Please confirm your account via email.')
    end

    it 'fails when passwords do not match' do
      post :register, params: { email: 'test@example.com', password: 'password', password_confirmation: 'wrong' }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST #login' do
    it 'logs in a confirmed user successfully' do
      post :login, params: { email: user.email, password: user.password }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('token')
    end

    it 'fails for unconfirmed user' do
      post :login, params: { email: unconfirmed_user.email, password: unconfirmed_user.password }
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['error']).to eq('Your account has not been confirmed.')
    end

    it 'fails for banned user' do
      post :login, params: { email: banned_user.email, password: banned_user.password }
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['reason']).to eq('Violation of terms')
    end

    it 'fails with incorrect credentials' do
      post :login, params: { email: user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'fails after multiple failed attempts from the same IP' do
      5.times do
        post :login, params: { email: user.email, password: 'wrongpassword' }
      end
      post :login, params: { email: user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:too_many_requests)
      expect(JSON.parse(response.body)['error']).to eq('Too many failed attempts. Please try again in one hour.')
    end

    it 'fails when account is locked due to too many failed login attempts' do
      user.lock_access!
      post :login, params: { email: user.email, password: user.password }
      expect(response).to have_http_status(:too_many_requests)
      expect(JSON.parse(response.body)['error']).to eq('Too many failed attempts. Please try again in one hour.')
    end
  end

  describe 'POST #resend_confirmation' do
    it 'sends confirmation instructions if user is unconfirmed' do
      post :resend_confirmation, params: { email: unconfirmed_user.email }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Confirmation instructions sent.')
    end

    it 'returns already confirmed message for confirmed user' do
      post :resend_confirmation, params: { email: user.email }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('The account has already been confirmed.')
    end
  end

  describe 'POST #logout' do
    before do
      sign_in user
    end

    it 'logs out the user successfully' do
      post :logout
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Successfully logged out.')
    end
  end
end
