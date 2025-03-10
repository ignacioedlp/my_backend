class ApplicationController < ActionController::API
  include Pundit

  # Desactivar la verificación de CSRF para solicitudes JSON (como en APIs)
  protect_from_forgery with: :null_session

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: { error: 'You are not authorized' }, status: :forbidden
  end
end
