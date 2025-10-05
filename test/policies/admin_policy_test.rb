require "test_helper"

class AdminPolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user)
    @provider_user = users(:provider_user)
    @patient_user = users(:patient_user)
  end

  test "admin user can access admin namespace" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.admin_user?, "Admin user should be able to access admin namespace"
    assert policy.access?, "Admin user should have access"
  end

  test "provider user cannot access admin namespace" do
    policy = AdminPolicy.new(@provider_user, :admin)
    assert_not policy.admin_user?, "Provider user should not be able to access admin namespace"
    assert_not policy.access?, "Provider user should not have access"
  end

  test "patient user cannot access admin namespace" do
    policy = AdminPolicy.new(@patient_user, :admin)
    assert_not policy.admin_user?, "Patient user should not be able to access admin namespace"
    assert_not policy.access?, "Patient user should not have access"
  end

  test "guest user cannot access admin namespace" do
    policy = AdminPolicy.new(nil, :admin)
    assert_not policy.admin_user?, "Guest user should not be able to access admin namespace"
    assert_not policy.access?, "Guest user should not have access"
  end

  test "admin can view dashboard" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.dashboard?, "Admin should be able to view dashboard"
  end

  test "admin can manage users" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.manage_users?, "Admin should be able to manage users"
  end

  test "admin can manage provider profiles" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.manage_provider_profiles?, "Admin should be able to manage provider profiles"
  end

  test "admin can view appointments" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.view_appointments?, "Admin should be able to view appointments"
  end

  test "admin can view payments" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.view_payments?, "Admin should be able to view payments"
  end

  test "non-admin cannot view dashboard" do
    policy = AdminPolicy.new(@provider_user, :admin)
    assert_not policy.dashboard?, "Non-admin should not be able to view dashboard"
  end

  test "non-admin cannot manage users" do
    policy = AdminPolicy.new(@patient_user, :admin)
    assert_not policy.manage_users?, "Non-admin should not be able to manage users"
  end

  # Test standard Pundit CRUD methods
  test "admin can perform index action" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.index?, "Admin should be able to perform index action"
  end

  test "admin can perform show action" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.show?, "Admin should be able to perform show action"
  end

  test "admin can perform create action" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.create?, "Admin should be able to perform create action"
    assert policy.new?, "Admin should be able to perform new action"
  end

  test "admin can perform update action" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.update?, "Admin should be able to perform update action"
    assert policy.edit?, "Admin should be able to perform edit action"
  end

  test "admin can perform destroy action" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.destroy?, "Admin should be able to perform destroy action"
  end

  test "non-admin cannot perform any CRUD actions" do
    policy = AdminPolicy.new(@provider_user, :admin)
    assert_not policy.index?, "Non-admin should not be able to perform index action"
    assert_not policy.show?, "Non-admin should not be able to perform show action"
    assert_not policy.create?, "Non-admin should not be able to perform create action"
    assert_not policy.update?, "Non-admin should not be able to perform update action"
    assert_not policy.destroy?, "Non-admin should not be able to perform destroy action"
  end

  # Test Scope
  test "admin scope resolves to all records" do
    scope = AdminPolicy::Scope.new(@admin_user, User.all)
    assert_equal User.count, scope.resolve.count, "Admin scope should return all users"
  end

  test "non-admin scope resolves to none" do
    scope = AdminPolicy::Scope.new(@provider_user, User.all)
    assert_equal 0, scope.resolve.count, "Non-admin scope should return no users"
  end

  test "guest scope resolves to none" do
    scope = AdminPolicy::Scope.new(nil, User.all)
    assert_equal 0, scope.resolve.count, "Guest scope should return no users"
  end
end
