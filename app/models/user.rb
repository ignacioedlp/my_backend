class User < ApplicationRecord
  rolify
  audited
  has_one_attached :avatar

  # ✅ Enabled Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable,
         :omniauthable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist,
         omniauth_providers: [ :github, :google_oauth2 ]

  # Attributes available for Ransack queries
  def self.ransackable_attributes(auth_object = nil)
    [
      "ban_reason", "banned", "banned_at", "confirmation_sent_at", "confirmation_token", "confirmed_at",
      "created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password",
      "failed_attempts", "id", "id_value", "last_sign_in_at", "last_sign_in_ip", "locked_at", "name",
      "provider", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count",
      "uid", "unconfirmed_email", "unlock_token", "updated_at"
    ]
  end

  # Handles user authentication via Omniauth
  def self.from_omniauth(auth)
    existing_user = User.find_by(email: auth.info.email)

    if existing_user
      if existing_user.provider.nil?
        # Update provider and UID if the user originally registered with email/password
        existing_user.update(provider: auth.provider, uid: auth.uid)
        existing_user
      elsif existing_user.provider == auth.provider
        # Return user if the provider matches
        existing_user
      else
        # Conflict if the email exists with a different provider
        :provider_mismatch
      end
    else
      # Create a new user if one doesn't exist
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

  # Useful scopes
  scope :banned, -> { where(banned: true) }
  scope :active, -> { where(banned: false) }

  # JWT revocation strategy to prevent access for banned or locked users
  def self.jwt_revoked?(payload, user)
    user.banned? || user.access_locked?
  end

  # Placeholder method for JWT revocation
  def self.revoke_jwt(payload, user); end

  # Generate JWT token unless user is banned or locked
  def generate_jwt_token
    return nil if banned? || access_locked?
    Warden::JWTAuth::UserEncoder.new.call(self, :user, nil).first
  end

  def ban!(reason)
    update(banned: true, ban_reason: reason, banned_at: Time.current)
  end

  def unban!
    update(banned: false, ban_reason: nil, banned_at: nil)
  end
end
