require "test_helper"

class AdminPolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user)
    @provider_user = users(:provider_user)
    @patient_user = users(:patient_user)
  end

  test "admin user can access admin namespace" do
    policy = AdminPolicy.new(@admin_user, :admin)
    assert policy.access?, "Admin user should be able to access admin namespace"
  end

  test "provider user cannot access admin namespace" do
    policy = AdminPolicy.new(@provider_user, :admin)
    assert_not policy.access?, "Provider user should not be able to access admin namespace"
  end

  test "patient user cannot access admin namespace" do
    policy = AdminPolicy.new(@patient_user, :admin)
    assert_not policy.access?, "Patient user should not be able to access admin namespace"
  end

  test "guest user cannot access admin namespace" do
    policy = AdminPolicy.new(nil, :admin)
    assert_not policy.access?, "Guest user should not be able to access admin namespace"
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
end
