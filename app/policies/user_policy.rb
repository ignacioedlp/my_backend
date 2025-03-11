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