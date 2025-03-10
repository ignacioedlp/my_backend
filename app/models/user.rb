class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # JWT Revocation Strategy
  def self.jwt_revoked?(payload, user)
    false
  end

  def self.revoke_jwt(payload, user)
  end
end
