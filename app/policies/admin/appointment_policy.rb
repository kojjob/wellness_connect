module Admin
  class AppointmentPolicy < AdminPolicy
    # Admins can view all appointments
    def index?
      admin_user?
    end

    def show?
      admin_user?
    end

    # Admins cannot create or edit appointments
    # Appointments are created by patients/providers only
    def create?
      false
    end

    def new?
      false
    end

    def edit?
      false
    end

    def update?
      false
    end

    # Admins cannot delete appointments (data integrity)
    # They can only view for support and dispute resolution
    def destroy?
      false
    end

    # Scope returns all appointments for admins
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
