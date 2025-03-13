module Api
  module V1
    class ApiController < ActionController::API
      include Pundit::Authorization
      before_action :authenticate_user!

      # Handle Pundit exceptions
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      # Handle Devise and JWT exceptions
      rescue_from JWT::DecodeError, with: :invalid_token
      rescue_from JWT::ExpiredSignature, with: :expired_token
      rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

      private

      # Retrieves the current authenticated user
      def current_user
        super || warden.authenticate(scope: :user)
      end

      # Renders an unauthorized response if no authenticated user is found
      def authenticate_user!
        render json: { error: "User not authenticated" }, status: :unauthorized unless current_user
      end

      # Renders a forbidden response if the user is not authorized
      def user_not_authorized
        render json: { error: "You do not have permission to perform this action" }, status: :forbidden
      end

      # Renders an unauthorized response for an invalid token
      def invalid_token
        render json: { error: "Invalid token" }, status: :unauthorized
      end

      # Renders an unauthorized response for an expired token
      def expired_token
        render json: { error: "Token has expired" }, status: :unauthorized
      end

      # Renders an unauthorized response when the user is not found
      def user_not_found
        render json: { error: "User not found" }, status: :unauthorized
      end
    end
  end
end
