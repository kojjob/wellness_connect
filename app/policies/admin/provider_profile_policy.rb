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

    # Admins cannot create provider profiles (providers create their own on signup)
    def create?
      false
    end

    def new?
      false
    end

    # Admins cannot delete provider profiles (data integrity)
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
