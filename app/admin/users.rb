# app/admin/users.rb
ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :banned, :ban_reason

  index do
    selectable_column
    id_column
    column :email
    column :confirmed do |user|
      user.confirmed? ? 'Yes' : 'No'
    end
    column :banned
    column :banned_at
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_at
    column :created_at
    actions
  end

  filter :email
  filter :banned
  filter :confirmed
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :banned
      f.input :ban_reason, as: :text
      f.input :banned_at
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :confirmed do
        user.confirmed? ? 'Yes' : 'No'
      end
      row :banned
      row :ban_reason
      row :banned_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :created_at
      row :updated_at
    end
  end

  action_item :ban, only: :show do
    if !user.banned?
      link_to 'Ban User', ban_admin_user_path(user), method: :post
    else
      link_to 'Unban User', unban_admin_user_path(user), method: :post
    end
  end

  member_action :ban, method: :post do
    user = User.find(params[:id])
    user.ban!('Banned by admin')
    redirect_to admin_user_path(user), notice: 'User has been banned.'
  end

  member_action :unban, method: :post do
    user = User.find(params[:id])
    user.unban!
    redirect_to admin_user_path(user), notice: 'User has been unbanned.'
  end
end