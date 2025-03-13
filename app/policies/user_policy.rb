class UserPolicy < ApplicationPolicy
  # Only admins can view the user index
  def index?
    user.has_role?(:admin)
  end

  # Admins can view any user; regular users can only view themselves
  def show?
    user.has_role?(:admin) || record == user
  end

  # Admins can update any user; regular users can update their own record
  def update?
    user.has_role?(:admin) || record == user
  end

  # Admins can delete any user; regular users can delete their own account
  def destroy?
    user.has_role?(:admin) || record == user
  end

  # Only admins can ban users, but they cannot ban themselves
  def ban?
    user.has_role?(:admin) && record != user
  end

  # Only admins can unban users
  def unban?
    user.has_role?(:admin)
  end

  # Scope to determine accessible records for a user
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
