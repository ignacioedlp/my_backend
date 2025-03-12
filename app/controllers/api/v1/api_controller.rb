module Api
  module V1
    class ApiController < ActionController::API
      include Pundit::Authorization
      before_action :authenticate_user!

      # 🔒 Rescatar errores de autorización de Pundit
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      # ⚠️ Rescatar errores de autenticación de Devise
      rescue_from JWT::DecodeError, with: :invalid_token
      rescue_from JWT::ExpiredSignature, with: :expired_token
      rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

      private

      # ✅ Devuelve el usuario actual autenticado por Devise + JWT
      def current_user
        super || warden.authenticate(scope: :user)
      end

      # ✅ Responde cuando el usuario no está autenticado
      def authenticate_user!
        render json: { error: "No autenticado" }, status: :unauthorized unless current_user
      end

      # 🚫 Responde cuando el usuario no tiene permisos
      def user_not_authorized
        render json: { error: "No autorizado" }, status: :forbidden
      end

      # 🚫 Token inválido
      def invalid_token
        render json: { error: "Token inválido" }, status: :unauthorized
      end

      # ⏰ Token expirado
      def expired_token
        render json: { error: "Token expirado" }, status: :unauthorized
      end

      # 🧑‍🚫 Usuario no encontrado con el token
      def user_not_found
        render json: { error: "Usuario no encontrado" }, status: :unauthorized
      end
    end
  end
end
