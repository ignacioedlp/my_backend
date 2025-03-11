class Api::V1::PasswordsController < ApplicationController
    skip_before_action :verify_authenticity_token

    # Solicitar el cambio de contraseña
    def create
      user = User.find_by(email: params[:email])
  
      if user
        user.generate_reset_password_token!
        UserMailer.with(user: user).reset_password_email.deliver_now
        render json: { message: 'Instrucciones para restablecer la contraseña enviadas.' }, status: :ok
      else
        render json: { error: 'Correo electrónico no encontrado.' }, status: :not_found
      end
    end
  
    # Cambiar la contraseña con el token
    def update
      user = User.find_by(reset_password_token: params[:token])
  
      if user && user.reset_password_period_valid?
        if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          user.clear_reset_password_token!
          render json: { message: 'Contraseña actualizada correctamente.' }, status: :ok
        else
          render json: { error: user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Token inválido o expirado.' }, status: :unprocessable_entity
      end
    end
  end
  