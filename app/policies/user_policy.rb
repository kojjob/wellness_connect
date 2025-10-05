# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # Admin can do everything
  # Providers/Patients can only view/edit their own profile
  # Guests cannot do anything

  def index?
    user&.admin?
  end

  def show?
    user&.admin? || user == record
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin? || user == record
  end

  def destroy?
    user&.admin?
  end

  def suspend?
    user&.admin?
  end

  def unsuspend?
    user&.admin?
  end

  def block?
    user&.admin?
  end

  def unblock?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user
        scope.where(id: user.id)
      else
        scope.none
      end
    end
  end
end
