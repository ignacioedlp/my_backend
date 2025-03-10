class Api::V1::AuthController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!, only: [:logout]
  
    # POST /api/v1/register
    def register
      user = User.new(sign_up_params)
  
      if user.save
        user.add_role(:default)
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        render json: { message: 'User registered successfully', token: token }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # POST /api/v1/login
    def login
      user = User.find_for_database_authentication(email: params[:email])
      if user&.valid_password?(params[:password])
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        render json: { token: token }, status: :ok
      else
        render json: { error: 'Invalid Email or Password' }, status: :unauthorized
      end
    end
  
    # DELETE /api/v1/logout
    def logout
      current_user.jwt_revocation_strategy.revoke_jwt(request.env['warden-jwt_auth.token'], current_user)
      render json: { message: 'Logged out successfully' }, status: :ok
    end
  
    private
  
    def sign_up_params
      params.permit(:email, :password, :password_confirmation)
    end
  end
  