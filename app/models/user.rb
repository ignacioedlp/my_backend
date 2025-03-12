class User < ApplicationRecord
  rolify
  audited
  has_one_attached :avatar

  # ✅ Módulos de Devise habilitados
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable,
         :omniauthable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist,
         omniauth_providers: [ :github ]

  def self.ransackable_attributes(auth_object = nil)
    [ "ban_reason", "banned", "banned_at", "confirmation_sent_at", "confirmation_token", "confirmed_at", "created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password", "failed_attempts", "id", "id_value", "last_sign_in_at", "last_sign_in_ip", "locked_at", "name", "provider", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "uid", "unconfirmed_email", "unlock_token", "updated_at" ]
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.confirmed_at = Time.current
      user.name = auth.info.name
    end
  end

  # Scopes útiles
  scope :banned, -> { where(banned: true) }
  scope :active, -> { where(banned: false) }

  # JWT Revocation Strategy
  def self.jwt_revoked?(payload, user)
    user.banned? || user.access_locked?
  end

  def self.revoke_jwt(payload, user); end

  def generate_jwt_token
    return nil if banned? || access_locked?
    Warden::JWTAuth::UserEncoder.new.call(self, :user, nil).first
  end
end
