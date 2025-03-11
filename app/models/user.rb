class User < ApplicationRecord
  rolify
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
end
