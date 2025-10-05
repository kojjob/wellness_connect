module Admin
  class UserPolicy < AdminPolicy
    # Only super_admins can create and manage users
    # Regular admins can view users but not create/edit/delete them

    def index?
      admin_user? || super_admin_user?
    end

    def show?
      admin_user? || super_admin_user?
    end

    # Only super_admins can create users
    def new?
      super_admin_user?
    end

    def create?
      super_admin_user?
    end

    # Only super_admins can update users
    def update?
      super_admin_user?
    end

    def edit?
      update?
    end

    # Only super_admins can delete users (and prevent deleting themselves)
    def destroy?
      super_admin_user? && record.id != user.id
    end

    # Only super_admins can change user roles
    def change_role?
      super_admin_user?
    end

    # Only super_admins can suspend/unsuspend users
    def suspend?
      super_admin_user?
    end

    def unsuspend?
      super_admin_user?
    end

    # Only super_admins can block/unblock users
    def block?
      super_admin_user?
    end

    def unblock?
      super_admin_user?
    end

    # Scope returns all users for admins and super_admins
    class Scope < AdminPolicy::Scope
      def resolve
        if user&.admin? || user&.super_admin?
          scope.all
        else
          scope.none
        end
      end
    end

    private

    def super_admin_user?
      user&.super_admin?
    end
  end
end
