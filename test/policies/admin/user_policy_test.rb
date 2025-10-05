require "test_helper"

module Admin
  class UserPolicyTest < ActiveSupport::TestCase
    def setup
      @admin_user = users(:admin_user)
      @provider_user = users(:provider_user)
      @patient_user = users(:patient_user)
    end

    test "admin can view users index" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert policy.index?, "Admin should be able to view users index"
    end

    test "admin can view user details" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert policy.show?, "Admin should be able to view user details"
    end

    test "admin can edit user" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert policy.edit?, "Admin should be able to edit user"
      assert policy.update?, "Admin should be able to update user"
    end

    test "admin can delete other users" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert policy.destroy?, "Admin should be able to delete other users"
    end

    test "admin cannot delete themselves" do
      policy = Admin::UserPolicy.new(@admin_user, @admin_user)
      assert_not policy.destroy?, "Admin should not be able to delete themselves"
    end

    test "admin can change user roles" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert policy.change_role?, "Admin should be able to change user roles"
    end

    test "non-admin cannot access user management" do
      policy = Admin::UserPolicy.new(@provider_user, @patient_user)
      assert_not policy.index?, "Non-admin should not access users index"
      assert_not policy.show?, "Non-admin should not view user details"
      assert_not policy.update?, "Non-admin should not update users"
      assert_not policy.destroy?, "Non-admin should not delete users"
      assert_not policy.change_role?, "Non-admin should not change roles"
    end

    # Test Scope
    test "admin scope resolves to all users" do
      scope = Admin::UserPolicy::Scope.new(@admin_user, User.all)
      assert_equal User.count, scope.resolve.count, "Admin scope should return all users"
    end

    test "non-admin scope resolves to none" do
      scope = Admin::UserPolicy::Scope.new(@provider_user, User.all)
      assert_equal 0, scope.resolve.count, "Non-admin scope should return no users"
    end
  end
end
