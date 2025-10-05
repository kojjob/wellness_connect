class AppointmentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.patient?
        scope.where(patient: user)
      elsif user.provider?
        scope.where(provider: user)
      else
        scope.none
      end
    end
  end

  def show?
    user.patient? && record.patient == user || user.provider? && record.provider == user
  end

  def create?
    user.patient?
  end

  def cancel?
    # Patients and providers can cancel their own appointments
    (user.patient? && record.patient == user) || (user.provider? && record.provider == user)
  end

  def update?
    cancel?
  end
end
