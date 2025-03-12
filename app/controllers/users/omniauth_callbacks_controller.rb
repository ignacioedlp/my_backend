class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Saltar la verificación CSRF solo para el callback de GitHub
  skip_before_action :verify_authenticity_token, only: %i[github google_oauth2]
  # Desactivar el almacenamiento de la sesión para el callback
  skip_before_action :verify_authenticity_token, raise: false

  def google_oauth2
    handle_auth("Google")
  end

  def github
    handle_auth("GitHub")
  end

  def handle_auth(kind)
    user = User.from_omniauth(request.env["omniauth.auth"])

    case user
    when :provider_mismatch
      render json: { error: "Ya existe una cuenta con ese correo registrada con otro proveedor." }, status: :conflict
    when User
      token = user.generate_jwt_token
      render json: { token: token, message: "Successfully authenticated from #{kind}." }
    else
      render json: { error: "#{kind} Authentication failed" }, status: :unauthorized
    end
  end

  def failure
    render json: { error: "Authentication failed" }, status: :unauthorized
  end
end
