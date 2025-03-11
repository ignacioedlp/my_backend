module Api
  module V1
    class ApiController < ActionController::API
      include Pundit::Authorization
      
      # Add JWT authentication for API
      before_action :authenticate_user!
      
      # Handle unauthorized Pundit errors
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      
      private
      
      def user_not_authorized
        render json: { error: 'No autorizado' }, status: :forbidden
      end
      
      # This method is needed for Pundit
      def current_user
        @current_user ||= begin
          token = request.headers['Authorization']&.split(' ')&.last
          if token
            payload = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256' }).first rescue nil
            
            User.find_by(id: payload['sub']) if payload
          end
        end
      end
      
      # Define authenticate_user! for API controllers
      def authenticate_user!
        render json: { error: 'No autenticado' }, status: :unauthorized unless current_user
      end
    end
  end
end
