class AddTrackingFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    # Campos para trackear logins
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
    
    # Campos para banear usuarios
    add_column :users, :banned, :boolean, default: false
    add_column :users, :banned_at, :datetime
    add_column :users, :ban_reason, :string
    
    # Campos para confirmación de cuenta
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    
    # Índices para mejorar el rendimiento
    add_index :users, :confirmation_token, unique: true
    add_index :users, :banned
  end
end
