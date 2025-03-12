class Api::V1::AuthController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    MAX_LOGIN_ATTEMPTS = 5
    BLOCK_TIME = 1.hour

    # POST /api/v1/register
    def register
      user = User.new(sign_up_params)
  
      if user.save
        user.add_role(:default)
        # Enviar instrucciones de confirmación
        user.send_confirmation_instructions
        render json: { message: 'Usuario registrado correctamente. Por favor, confirma tu cuenta a través del correo electrónico.' }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # POST /api/v1/login
    def login
      ip = request.remote_ip
      if blocked?(ip)
        return render json: { error: "Too many failed attempts. Please try again later." }, status: :too_many_requests
      end

      user = User.find_for_database_authentication(email: params[:email])
      
      # Verificar si el usuario existe y si la contraseña es válida
      if user.nil? || !user.valid_password?(params[:password])
        increment_failed_attempts(ip)
        render json: { error: 'Email o contraseña inválidos' }, status: :unauthorized
        return
      end
      
      # Verificar si el usuario está baneado
      if user.banned?
        render json: { error: 'Tu cuenta ha sido suspendida', reason: user.ban_reason }, status: :forbidden
        return
      end
      
      # Verificar si el usuario ha confirmado su cuenta
      unless user.confirmed?
        render json: { error: 'Tu cuenta no ha sido confirmada', message: 'Por favor, confirma tu cuenta a través del correo electrónico' }, status: :forbidden
        return
      end
      
      # Actualizar información de inicio de sesión
      user.track_sign_in(request.remote_ip)
      
      # Generar token JWT
      token = user.generate_jwt_token
      render json: { token: token }, status: :ok
    end
    
    # GET /api/v1/confirm_account
    def confirm_account
      token = params[:token]
      user = User.find_by(confirmation_token: token)
      
      if user.nil?
        render json: { error: 'Token de confirmación inválido' }, status: :bad_request
        return
      end
      
      if !user.confirmation_period_valid?
        render json: { error: 'El token de confirmación ha expirado', message: 'Solicita un nuevo token de confirmación' }, status: :bad_request
        return
      end
      
      user.confirm!
      render json: { message: 'Cuenta confirmada correctamente' }, status: :ok
    end
    
    # POST /api/v1/resend_confirmation
    def resend_confirmation
      user = User.find_by(email: params[:email])
      
      if user.nil?
        render json: { error: 'Usuario no encontrado' }, status: :not_found
        return
      end
      
      if user.confirmed?
        render json: { message: 'La cuenta ya ha sido confirmada' }, status: :ok
        return
      end
      
      user.resend_confirmation_instructions
      render json: { message: 'Instrucciones de confirmación enviadas' }, status: :ok
    end
  
    private
  
    def sign_up_params
      params.permit(:email, :password, :password_confirmation)
    end

    # 🚨 Verificar si la IP está bloqueada
    def blocked?(ip)
      $redis.with do |conn|
        attempts = conn.get(failed_attempts_key(ip)).to_i
        attempts >= MAX_LOGIN_ATTEMPTS
      end
    end

    # 🔥 Incrementar intentos fallidos y establecer expiración
    def increment_failed_attempts(ip)
      $redis.with do |conn|
        key = failed_attempts_key(ip)
        attempts = conn.incr(key)
        conn.expire(key, BLOCK_TIME) if attempts == 1
      end
    end

    # ✅ Resetear intentos fallidos tras un login exitoso
    def reset_failed_attempts(ip)
      $redis.with do |conn|
        conn.del(failed_attempts_key(ip))
      end
    end

    # 🔑 Generar la clave para Redis
    def failed_attempts_key(ip)
      "login:failed_attempts:#{ip}"
    end
  end