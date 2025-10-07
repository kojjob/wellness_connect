module Admin
  class PatientProfilePolicy < AdminPolicy
    # Admins can view and manage all patient profiles
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

    # Admins cannot create patient profiles (patients create their own on signup)
    def create?
      false
    end

    def new?
      false
    end

    # Admins cannot delete patient profiles (data integrity)
    def destroy?
      false
    end

    # Scope returns all patient profiles for admins and super_admins
    class Scope < AdminPolicy::Scope
      def resolve
        if user&.admin? || user&.super_admin?
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
