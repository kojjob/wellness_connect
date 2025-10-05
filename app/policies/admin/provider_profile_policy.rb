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

    # Admins can create provider profiles for users with provider role
    def create?
      admin_user?
    end

    def new?
      admin_user?
    end

    # Admins can delete provider profiles when necessary
    def destroy?
      admin_user?
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
