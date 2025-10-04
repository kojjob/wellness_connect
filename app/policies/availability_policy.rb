class AvailabilityPolicy < ApplicationPolicy
  def index?
    true # Anyone can view availabilities
  end

  def show?
    true # Anyone can view a specific availability
  end

  def new?
    user.present? && user.provider? && user.provider_profile == record.provider_profile
  end

  def create?
    user.present? && user.provider? && user.provider_profile == record.provider_profile
  end

  def edit?
    user.present? && user.provider? && user.provider_profile == record.provider_profile
  end

  def update?
    user.present? && user.provider? && user.provider_profile == record.provider_profile
  end

  def destroy?
    user.present? && user.provider? && user.provider_profile == record.provider_profile
  end
end
