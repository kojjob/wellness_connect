module Admin
  class ProviderProfilePolicy < AdminPolicy
    # Admins can view and manage all provider profiles
    def index?
      admin_user?
    end

    def show?
      admin_user?
    end

    def edit?
      admin_user?
    end

    def update?
      admin_user?
    end

    # Admins cannot delete provider profiles (to maintain data integrity)
    # Instead, they should deactivate the associated user
    def destroy?
      false
    end

    # Scope returns all provider profiles for admins
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
