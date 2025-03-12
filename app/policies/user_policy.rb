class UserPolicy < ApplicationPolicy
    def index?
      user.has_role?(:admin)
    end

    def show?
      user.has_role?(:admin) || record == user
    end

    def update?
      user.has_role?(:admin) || record == user
    end

    def destroy?
      user.has_role?(:admin) || record == user
    end

    # Solo los administradores pueden banear usuarios
    def ban?
      user.has_role?(:admin) && record != user # Un admin no puede banearse a sí mismo
    end

    # Solo los administradores pueden desbanear usuarios
    def unban?
      user.has_role?(:admin)
    end

    class Scope < Scope
      def resolve
        if user.has_role?(:admin)
          scope.all
        else
          scope.where(id: user.id)
        end
      end
    end
end
