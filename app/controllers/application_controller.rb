class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :null_session

  def current_user
    super || warden.authenticate(scope: :user)
  end

  # Renders an unauthorized response if no authenticated user is found
  def authenticate_user!
    render json: { error: "User not authenticated" }, status: :unauthorized unless current_user
  end
end
