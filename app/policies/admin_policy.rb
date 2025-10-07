# Base policy for all admin namespace policies
# Ensures only admin users can perform any actions
class AdminPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Only admins and super_admins can access admin namespace
  def admin_user?
    user&.admin? || user&.super_admin?
  end

  # Check if user is a super admin
  def super_admin_user?
    user&.super_admin?
  end

  # Backward compatibility methods
  def access?
    admin_user?
  end

  def dashboard?
    access?
  end

  def manage_users?
    access?
  end

  def manage_provider_profiles?
    access?
  end

  def view_appointments?
    access?
  end

  def view_payments?
    access?
  end

  # Standard Pundit CRUD methods - default to admin_user?
  def index?
    admin_user?
  end

  def show?
    admin_user?
  end

  def create?
    admin_user?
  end

  def new?
    create?
  end

  def update?
    admin_user?
  end

  def edit?
    update?
  end

  def destroy?
    admin_user?
  end

  # Scope for index actions
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.admin? || user&.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
