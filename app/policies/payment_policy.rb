class PaymentPolicy < ApplicationPolicy
  # Users can view payments list
  def index?
    user.present?
  end

  # Users can view their own payments
  def show?
    owns_payment? || user.admin?
  end

  # Only patients can create payments for their appointments
  def create?
    user.patient?
  end

  # Refund policy - admins or the provider who received the payment
  def refund?
    user.admin? || (user.provider? && record.appointment&.provider == user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.provider?
        # Providers see payments for their appointments
        scope.joins(:appointment).where(appointments: { provider_id: user.id })
      else
        # Patients see their own payments
        scope.where(payer: user)
      end
    end
  end

  private

  def owns_payment?
    return false unless record.respond_to?(:payer)

    # Payer owns the payment
    return true if record.payer == user

    # Provider of the appointment can view the payment
    return true if user.provider? && record.appointment&.provider == user

    false
  end
end
