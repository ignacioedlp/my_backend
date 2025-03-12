class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_user
    super || warden.authenticate(scope: :user)
  end

  # ✅ Responde cuando el usuario no está autenticado
  def authenticate_user!
    render json: { error: "No autenticado" }, status: :unauthorized unless current_user
  end
end
