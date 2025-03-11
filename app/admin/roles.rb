ActiveAdmin.register Role do
  # Permitimos parámetros necesarios para la creación y edición
  permit_params :name, user_ids: []

  # 🎯 Configuración de la lista de roles
  index do
    selectable_column
    id_column
    column :name
    column "Usuarios Asociados" do |role|
      role.users.pluck(:email).join(", ")
    end
    actions
  end

  # 🎯 Mostrar detalles del rol
  show do
    attributes_table do
      row :id
      row :name
      row "Usuarios Asociados" do |role|
        role.users.pluck(:email).join(", ")
      end
      row :created_at
      row :updated_at
    end
  end

  # 🎯 Formulario para crear/editar roles
  form do |f|
    f.semantic_errors
    f.inputs "Detalles del Rol" do
      f.input :name
      f.input :users, as: :check_boxes, collection: User.all.map { |u| [u.email, u.id] }
    end
    f.actions
  end

  # 🎯 Filtros para buscar en la vista de index
  filter :name
  filter :users, as: :select, collection: proc { User.all.pluck(:email, :id) }
  filter :created_at
end
