module Admin
  class PaymentPolicy < AdminPolicy
    # Admins can view all payments
    def index?
      admin_user?
    end

    def show?
      admin_user?
    end

    # Admins cannot create or edit payments
    # Payments are created through Stripe integration only
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

    # Admins cannot delete payments (financial record integrity)
    def destroy?
      false
    end

    # Future: Allow admins to issue refunds
    def refund?
      admin_user?
    end

    # Scope returns all payments for admins
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
