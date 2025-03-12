class User < ApplicationRecord
  rolify
  audited
  has_one_attached :avatar

  # ✅ Módulos de Devise habilitados
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

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
