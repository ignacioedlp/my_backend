ActiveAdmin.register User do
    # Permitimos modificar el email y los roles
    permit_params :email, role_ids: []
  
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
  
    # 🎯 Invalidar el token JWT cuando se actualiza el usuario
    controller do
      def update
        user = User.find(params[:id])
        if user.update(permitted_params[:user])
          redirect_to admin_user_path(user), notice: "Usuario actualizado"
        else
          render :edit
        end
      end
    end
  end
  