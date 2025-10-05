module Admin
  class UserPolicy < AdminPolicy
    # Admins can manage all users
    def index?
      admin_user?
    end

    def show?
      admin_user?
    end

    def update?
      admin_user?
    end

    def edit?
      update?
    end

    # Prevent admins from deleting themselves
    def destroy?
      admin_user? && record.id != user.id
    end

    # Admin can change user roles
    def change_role?
      admin_user?
    end

    # Scope returns all users for admins
    class Scope < AdminPolicy::Scope
      def resolve
        if user&.admin?
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
