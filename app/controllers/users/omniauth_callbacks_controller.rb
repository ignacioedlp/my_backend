class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Saltar la verificación CSRF solo para el callback de GitHub
  skip_before_action :verify_authenticity_token, only: :github
  # Desactivar el almacenamiento de la sesión para el callback
  skip_before_action :verify_authenticity_token, raise: false

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      # Para APIs, puedes generar un token JWT y devolverlo
      token = JWT.encode({ user_id: @user.id }, Rails.application.credentials.secret_key_base)
      render json: { token: token, message: "Successfully authenticated from GitHub." }
    else
      render json: { error: 'Authentication failed' }, status: :unauthorized
    end
  end

  def failure
    render json: { error: 'Authentication failed' }, status: :unauthorized
  end
end
