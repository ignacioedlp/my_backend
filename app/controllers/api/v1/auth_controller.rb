class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  MAX_LOGIN_ATTEMPTS = 5
  BLOCK_TIME = 1.hour

  # POST /api/v1/register
  def register
    user = User.new(sign_up_params)
    if user.save
      user.send_confirmation_instructions
      render json: { message: 'Usuario registrado correctamente. Confirma tu cuenta a través del correo.' }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/login
  def login
    ip = request.remote_ip

    # 🔒 Bloqueo por IP
    if blocked_ip?(ip)
      return render json: { error: 'Demasiados intentos fallidos. Inténtalo nuevamente en una hora.' }, status: :too_many_requests
    end

    user = User.find_for_database_authentication(email: params[:email])

    # 🔒 Bloqueo por usuario (Devise :lockable)
    if user.access_locked?
      return render json: { error: 'Tu cuenta está bloqueada por demasiados intentos fallidos.' }, status: :forbidden
    end

    if user.nil? || !user.valid_password?(params[:password])
      increment_failed_attempts(ip)
      render json: { error: 'Email o contraseña inválidos' }, status: :unauthorized
      return
    end

    if user.banned?
      render json: { error: 'Tu cuenta ha sido suspendida', reason: user.ban_reason }, status: :forbidden
      return
    end

    unless user.confirmed?
      render json: { error: 'Tu cuenta no ha sido confirmada.' }, status: :forbidden
      return
    end

    # ✅ Resetear intentos tras login exitoso
    reset_failed_attempts(ip)
    user.unlock_access! if user.access_locked?

    token = user.generate_jwt_token
    render json: { token: token }, status: :ok
  end

  # POST /api/v1/resend_confirmation
  def resend_confirmation
    user = User.find_by(email: params[:email])
    if user&.confirmed?
      render json: { message: 'La cuenta ya ha sido confirmada' }, status: :ok
    else
      user.resend_confirmation_instructions
      render json: { message: 'Instrucciones de confirmación enviadas' }, status: :ok
    end
  end

  private

  def sign_up_params
    params.permit(:email, :password, :password_confirmation)
  end

  # 🚨 Verificar si la IP está bloqueada
  def blocked_ip?(ip)
    $redis.with do |conn|
      attempts = conn.get(failed_attempts_key(ip)).to_i
      attempts >= MAX_LOGIN_ATTEMPTS
    end
  end

  # 🔥 Incrementar intentos fallidos y establecer expiración en Redis
  def increment_failed_attempts(ip)
    $redis.with do |conn|
      key = failed_attempts_key(ip)
      attempts = conn.incr(key)
      conn.expire(key, BLOCK_TIME) if attempts == 1
    end
  end

  # ✅ Resetear intentos fallidos tras login exitoso
  def reset_failed_attempts(ip)
    $redis.with { |conn| conn.del(failed_attempts_key(ip)) }
  end

  # 🔑 Generar la clave para Redis
  def failed_attempts_key(ip)
    "login:failed_attempts:#{ip}"
  end
end
