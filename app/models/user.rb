class User < ApplicationRecord
  rolify
  audited
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "id_value", "remember_created_at", "reset_password_sent_at", "reset_password_token", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["roles"]
  end

  # JWT Revocation Strategy
  def self.jwt_revoked?(payload, user)
    false
  end

  def self.revoke_jwt(payload, user)
  end

  def generate_jwt_token
    Warden::JWTAuth::UserEncoder.new.call(self, :user, nil).first
  end

  # Generar un token de reseteo con tiempo de expiración
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.hex(10)
    self.reset_password_sent_at = Time.current
    save!
  end

  # Verificar si el token está dentro del período de validez (2 horas por defecto)
  def reset_password_period_valid?
    reset_password_sent_at && reset_password_sent_at >= 2.hours.ago
  end

  # Limpiar el token después de cambiar la contraseña
  def clear_reset_password_token!
    update(reset_password_token: nil, reset_password_sent_at: nil)
  end
end
