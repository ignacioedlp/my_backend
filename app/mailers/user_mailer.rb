class UserMailer < ApplicationMailer
    default from: 'no-reply@example.com'
  
    def reset_password_email
      @user = params[:user]
      @token = @user.reset_password_token
      @url  = "#{ENV['FRONTEND_URL']}/reset-password?token=#{@token}"
      mail(to: @user.email, subject: 'Instrucciones para restablecer tu contraseña')
    end
  end