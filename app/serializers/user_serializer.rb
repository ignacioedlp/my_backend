class UserSerializer
  include JSONAPI::Serializer

  # Basic user attributes
  attributes :id, :email, :created_at, :updated_at

  # Login tracking fields
  attributes :sign_in_count, :current_sign_in_at, :last_sign_in_at

  # Account confirmation status
  attribute :confirmed do |user|
    user.confirmed?
  end

  attribute :confirmed_at

  # Ban status of the user
  attribute :banned do |user|
    user.banned?
  end

  attribute :banned_at

  # Display ban reason only if the user is banned
  attribute :ban_reason do |user|
    user.banned? ? user.ban_reason : nil
  end

  # List of user roles
  attribute :roles do |user|
    user.roles.map(&:name)
  end
end
