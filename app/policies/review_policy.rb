class ReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # Users can see all reviews (for browsing provider profiles)
        scope.all
      end
    end
  end

  def index?
    true # Anyone can view reviews
  end

  def show?
    true # Anyone can view a specific review
  end

  def create?
    # Only patients who have had completed appointments with the provider can leave reviews
    return false unless user.patient?
    return false unless record.provider_profile.present?

    # Check if user has had a completed appointment with this provider
    Appointment.exists?(
      patient: user,
      provider: record.provider_profile.user,
      status: "completed"
    )
  end

  def new?
    create?
  end

  def update?
    # Only the review author can update their own review
    user.patient? && record.reviewer == user
  end

  def edit?
    update?
  end

  def destroy?
    # Review author or admin can delete
    (user.patient? && record.reviewer == user) || user.admin?
  end

  private

  def completed_appointment_exists?
    Appointment.exists?(
      patient: user,
      provider: record.provider_profile.user,
      status: "completed"
    )
  end
end
