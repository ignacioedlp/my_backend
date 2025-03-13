class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: [ :logout ]

  MAX_LOGIN_ATTEMPTS = 5
  BLOCK_TIME = 1.hour

  # POST /api/v1/register
  def register
    user = User.new(sign_up_params)
    if user.save
      user.send_confirmation_instructions
      render json: { message: "User registered successfully. Please confirm your account via email." }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/login
  def login
    ip = request.remote_ip

    # 🔒 Block IP after multiple failed attempts
    if blocked_ip?(ip)
      return render json: { error: "Too many failed attempts. Please try again in one hour." }, status: :too_many_requests
    end

    user = User.find_for_database_authentication(email: params[:email])

    if user.nil? || !user.valid_password?(params[:password])
      increment_failed_attempts(ip)
      render json: { error: "Invalid email or password" }, status: :unauthorized
      return
    end

    # 🔒 Lock account after multiple failed attempts (Devise :lockable)
    if user.access_locked?
      return render json: { error: "Your account is locked due to too many failed login attempts." }, status: :forbidden
    end

    if user.banned?
      render json: { error: "Your account has been suspended", reason: user.ban_reason }, status: :forbidden
      return
    end

    unless user.confirmed?
      render json: { error: "Your account has not been confirmed." }, status: :forbidden
      return
    end

    # ✅ Reset failed attempts after successful login
    reset_failed_attempts(ip)
    user.unlock_access! if user.access_locked?

    token = user.generate_jwt_token
    render json: { token: token }, status: :ok
  end

  # POST /api/v1/resend_confirmation
  def resend_confirmation
    user = User.find_by(email: params[:email])
    if user&.confirmed?
      render json: { message: "The account has already been confirmed." }, status: :ok
    else
      user.resend_confirmation_instructions
      render json: { message: "Confirmation instructions sent." }, status: :ok
    end
  end

  # POST /api/v1/logout
  def logout
    sign_out(current_user)
    render json: { message: "Successfully logged out." }, status: :ok
  end

  private

  # Permit sign-up parameters
  def sign_up_params
    params.permit(:email, :password, :password_confirmation)
  end

  # 🚨 Check if the IP is blocked
  def blocked_ip?(ip)
    $redis.with do |conn|
      attempts = conn.get(failed_attempts_key(ip)).to_i
      attempts >= MAX_LOGIN_ATTEMPTS
    end
  end

  # 🔥 Increment failed attempts and set expiration in Redis
  def increment_failed_attempts(ip)
    $redis.with do |conn|
      key = failed_attempts_key(ip)
      attempts = conn.incr(key)
      conn.expire(key, BLOCK_TIME) if attempts == 1
    end
  end

  # ✅ Reset failed attempts after successful login
  def reset_failed_attempts(ip)
    $redis.with { |conn| conn.del(failed_attempts_key(ip)) }
  end

  # 🔑 Generate the Redis key for tracking failed attempts
  def failed_attempts_key(ip)
    "login:failed_attempts:#{ip}"
  end
end
