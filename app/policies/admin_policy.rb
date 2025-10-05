class AdminPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Main access control - only admins can access admin namespace
  def access?
    user&.admin?
  end

  # Dashboard access
  def dashboard?
    access?
  end

  # User management permissions
  def manage_users?
    access?
  end

  # Provider profile management permissions
  def manage_provider_profiles?
    access?
  end

  # Appointments viewing permissions
  def view_appointments?
    access?
  end

  # Payments viewing permissions
  def view_payments?
    access?
  end
end
