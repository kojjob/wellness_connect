module Admin
  class UserPolicy < AdminPolicy
    # Admins and super_admins can manage users
    # Admins can view, edit, and delete users (but not themselves)
    # Super_admins have same permissions (future: may have additional permissions)

    def index?
      admin_user? || super_admin_user?
    end

    def show?
      admin_user? || super_admin_user?
    end

    # Admins can create users
    def new?
      admin_user? || super_admin_user?
    end

    def create?
      admin_user? || super_admin_user?
    end

    # Admins can update users
    def update?
      admin_user? || super_admin_user?
    end

    def edit?
      update?
    end

    # Admins can delete users (but not themselves)
    def destroy?
      (admin_user? || super_admin_user?) && record.id != user.id
    end

    # Admins can change user roles
    def change_role?
      admin_user? || super_admin_user?
    end

    # Admins can suspend/unsuspend users
    def suspend?
      admin_user? || super_admin_user?
    end

    def unsuspend?
      admin_user? || super_admin_user?
    end

    # Admins can block/unblock users
    def block?
      admin_user? || super_admin_user?
    end

    def unblock?
      admin_user? || super_admin_user?
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
