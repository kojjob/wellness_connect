class AppointmentPolicy < ApplicationPolicy
  # Patients can create appointments
  def create?
    user.patient?
  end

  # Users can only view their own appointments
  def show?
    user_is_patient_or_provider?
  end

  # Users can view their own appointments list
  def index?
    user.present?
  end

  # Only patients can cancel their own appointments (>24h before)
  # Providers can cancel any of their appointments
  def cancel?
    return false unless user_is_patient_or_provider?

    if user.patient? && record.patient == user
      # Patients can cancel if >24 hours before appointment
      record.start_time > 24.hours.from_now
    elsif user.provider? && record.provider == user
      # Providers can cancel any of their appointments
      true
    elsif user.admin?
      # Admins can cancel any appointment
      true
    else
      false
    end
  end

  private

  def user_is_patient_or_provider?
    (user.patient? && record.patient == user) ||
    (user.provider? && record.provider == user) ||
    user.admin?
  end
end
