ActiveAdmin.register User do
  # Permitimos modificar el email, roles y la contraseña solo en creación
  permit_params :email, :password, :password_confirmation, role_ids: []

  # 🎯 Personalizamos la vista de lista
  index do
    selectable_column
    id_column
    column :email
    column :roles do |user|
      user.roles.pluck(:name).join(", ")
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  # 🎯 Filtros de búsqueda
  filter :email
  filter :roles, as: :select, collection: proc { Role.all.pluck(:name, :id) }
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  # 🎯 Formulario de edición/creación
  form do |f|
    f.inputs "Detalles del Usuario" do
      f.input :email
      # Mostrar campos de contraseña solo en creación
      if f.object.new_record?
        f.input :password, required: true
        f.input :password_confirmation, required: true
      end
      f.input :roles, as: :check_boxes, collection: Role.all
    end
    f.actions
  end

  # 🎯 Mostrar detalles del usuario
  show do
    attributes_table do
      row :email
      row :roles do |user|
        user.roles.pluck(:name).join(", ")
      end
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
      row :updated_at
    end
  end

  # 🎯 Controlador personalizado para lógica adicional
  controller do
    def create
      user = User.new(permitted_params[:user])

      if user.save
        redirect_to admin_user_path(user), notice: "Usuario creado correctamente."
      else
        render :new, alert: user.errors.full_messages.join(', ')
      end
    end

    def update
      user = User.find(params[:id])

      # Eliminar los campos de contraseña si están vacíos para evitar actualizaciones accidentales
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?

      if user.update(permitted_params[:user])
        redirect_to admin_user_path(user), notice: "Usuario actualizado correctamente."
      else
        render :edit, alert: user.errors.full_messages.join(', ')
      end
    end
  end
end
