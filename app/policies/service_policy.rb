class ServicePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def index?
    true # All authenticated users can view services
  end

  def show?
    true # All authenticated users can view a service
  end

  def new?
    user_owns_provider_profile? # Only the provider who owns the profile can create services
  end

  def create?
    user_owns_provider_profile? # Only the provider who owns the profile can create services
  end

  def edit?
    user_owns_provider_profile? # Only the provider who owns the profile can edit services
  end

  def update?
    user_owns_provider_profile? # Only the provider who owns the profile can update services
  end

  def destroy?
    user_owns_provider_profile? # Only the provider who owns the profile can destroy services
  end

  private

  def user_owns_provider_profile?
    record.provider_profile.user_id == user.id
  end
end
