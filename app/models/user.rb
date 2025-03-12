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
         omniauth_providers: [ :github, :google_oauth2 ]

  def self.ransackable_attributes(auth_object = nil)
    [ "ban_reason", "banned", "banned_at", "confirmation_sent_at", "confirmation_token", "confirmed_at", "created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password", "failed_attempts", "id", "id_value", "last_sign_in_at", "last_sign_in_ip", "locked_at", "name", "provider", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "uid", "unconfirmed_email", "unlock_token", "updated_at" ]
  end

  def self.from_omniauth(auth)
    # Buscar si ya existe un usuario con el mismo email
    existing_user = User.find_by(email: auth.info.email)

    if existing_user
      if existing_user.provider.nil?
        # Si el usuario se registró con email/password, lo actualizamos con el nuevo provider
        existing_user.update(provider: auth.provider, uid: auth.uid)
        existing_user
      elsif existing_user.provider == auth.provider
        # Si el provider coincide, retornamos el usuario
        existing_user
      else
        # El email ya existe con otro provider, se notifica del conflicto
        :provider_mismatch
      end
    else
      # Crear un nuevo usuario si no existe
      User.create(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0, 20],
        name: auth.info.name,
        confirmed_at: Time.current
      )
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
