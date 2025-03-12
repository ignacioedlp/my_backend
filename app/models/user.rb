class User < ApplicationRecord
  rolify
  audited
  has_one_attached :avatar

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Scopes para filtrar usuarios
  scope :banned, -> { where(banned: true) }
  scope :active, -> { where(banned: false) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "id_value", "remember_created_at", "reset_password_sent_at", "reset_password_token", "updated_at", 
     "sign_in_count", "current_sign_in_at", "last_sign_in_at", "banned", "confirmed_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["roles"]
  end

  # JWT Revocation Strategy
  def self.jwt_revoked?(payload, user)
    # Si el usuario está baneado, revocar todos los tokens
    user.banned?
  end

  def self.revoke_jwt(payload, user)
  end

  def generate_jwt_token
    # No generar tokens para usuarios baneados
    return nil if banned?
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

  # Métodos para trackear inicios de sesión
  def track_sign_in(ip_address)
    self.sign_in_count ||= 0
    self.sign_in_count += 1
    self.last_sign_in_at = current_sign_in_at
    self.last_sign_in_ip = current_sign_in_ip
    self.current_sign_in_at = Time.current
    self.current_sign_in_ip = ip_address
    save(validate: false)
  end

  # Métodos para banear usuarios
  def ban!(reason = nil, banned_at = Time.current.utc.to_time)
    update!(
      banned: true,
      banned_at: banned_at,
      ban_reason: reason
    )
  end

  def unban!
    update!(
      banned: nil,
      banned_at: nil,
      ban_reason: nil
    )
  end

  def banned?
    banned == true
  end

  # Métodos para confirmación de cuenta
  def confirmed?
    confirmed_at.present?
  end

  def generate_confirmation_token!
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.current.utc.to_time
    save!(validate: false)
  end

  def confirm!
    update(
      confirmed_at:  Time.current.utc,
      confirmation_token: nil
    )
  end

  def confirmation_period_valid?
    confirmation_sent_at && confirmation_sent_at >= 3.days.ago
  end

  def send_confirmation_instructions
    generate_confirmation_token! unless confirmation_token.present?
    UserMailer.confirmation_instructions(self).deliver_now
  end
  
  def resend_confirmation_instructions
    return true if confirmed?
    generate_confirmation_token!
    UserMailer.confirmation_instructions(self).deliver_now
  end
end
