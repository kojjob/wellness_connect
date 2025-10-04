class ProviderProfilePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def index?
    true # All authenticated users can view the list of provider profiles
  end

  def show?
    true # All authenticated users can view a provider profile
  end

  def new?
    user.present? && user.provider? # Only providers can create provider profiles
  end

  def create?
    user.present? && user.provider? # Only providers can create provider profiles
  end

  def edit?
    user_is_profile_owner? # Only the provider who owns the profile can edit it
  end

  def update?
    user_is_profile_owner? # Only the provider who owns the profile can update it
  end

  def destroy?
    user_is_profile_owner? # Only the provider who owns the profile can destroy it
  end

  private

  def user_is_profile_owner?
    user.present? && record.user_id == user.id
  end
end
