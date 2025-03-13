class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Skip CSRF verification only for GitHub and Google OAuth callbacks
  skip_before_action :verify_authenticity_token, only: %i[github google_oauth2]
  # Disable session storage for the callback
  skip_before_action :verify_authenticity_token, raise: false

  # Callback for Google OAuth2
  def google_oauth2
    handle_auth("Google")
  end

  # Callback for GitHub OAuth
  def github
    handle_auth("GitHub")
  end

  # Handles authentication for the given provider
  def handle_auth(kind)
    user = User.from_omniauth(request.env["omniauth.auth"])

    case user
    when :provider_mismatch
      render json: { error: "An account with this email already exists using a different provider." }, status: :conflict
    when User
      token = user.generate_jwt_token
      render json: { token: token, message: "Successfully authenticated from #{kind}." }
    else
      render json: { error: "#{kind} authentication failed." }, status: :unauthorized
    end
  end

  # Handles general authentication failure
  def failure
    render json: { error: "Authentication failed." }, status: :unauthorized
  end
end
