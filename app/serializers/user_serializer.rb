class UserSerializer
    include JSONAPI::Serializer
    attributes :id, :email, :created_at, :updated_at

    # Campos de seguimiento de inicios de sesión
    attributes :sign_in_count, :current_sign_in_at, :last_sign_in_at

    # Estado de la cuenta
    attribute :confirmed do |user|
      user.confirmed?
    end

    attribute :confirmed_at

    # Estado de baneo
    attribute :banned do |user|
      user.banned?
    end

    attribute :banned_at

    # Solo mostrar la razón del baneo si el usuario está baneado
    attribute :ban_reason do |user|
      user.banned? ? user.ban_reason : nil
    end

    # Roles del usuario
    attribute :roles do |user|
      user.roles.map(&:name)
    end
end
