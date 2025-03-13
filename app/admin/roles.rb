ActiveAdmin.register Role do
  permit_params :name, user_ids: []

  sidebar :audits, partial: "layouts/audits", only: :show

  index do
    selectable_column
    id_column
    column :name
    column "Users linked" do |role|
      role.users.pluck(:email).join(", ")
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row "Users linked" do |role|
        role.users.pluck(:email).join(", ")
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs "Rol details" do
      f.input :name
      f.input :users, as: :check_boxes, collection: User.all.map { |u| [ u.email, u.id ] }
    end
    f.actions
  end

  filter :name
  filter :users, as: :select, collection: proc { User.all.pluck(:email, :id) }
  filter :created_at
end
