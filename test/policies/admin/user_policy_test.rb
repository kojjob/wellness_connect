require "test_helper"

module Admin
  class UserPolicyTest < ActiveSupport::TestCase
    def setup
      @admin_user = users(:admin_user)
      @super_admin_user = users(:super_admin_user)
      @provider_user = users(:provider_user)
      @patient_user = users(:patient_user)
    end

    # ========================================
    # Regular Admin Tests
    # ========================================

    test "admin can view users index" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert policy.index?, "Admin should be able to view users index"
    end

    test "admin can view user details" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert policy.show?, "Admin should be able to view user details"
    end

    test "admin cannot edit user" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert_not policy.edit?, "Regular admin should not be able to edit user"
      assert_not policy.update?, "Regular admin should not be able to update user"
    end

    test "admin cannot create users" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert_not policy.new?, "Regular admin should not be able to access new user form"
      assert_not policy.create?, "Regular admin should not be able to create users"
    end

    test "admin cannot delete users" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert_not policy.destroy?, "Regular admin should not be able to delete users"
    end

    test "admin cannot change user roles" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert_not policy.change_role?, "Regular admin should not be able to change user roles"
    end

    test "admin cannot suspend users" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert_not policy.suspend?, "Regular admin should not be able to suspend users"
      assert_not policy.unsuspend?, "Regular admin should not be able to unsuspend users"
    end

    test "admin cannot block users" do
      policy = Admin::UserPolicy.new(@admin_user, @patient_user)
      assert_not policy.block?, "Regular admin should not be able to block users"
      assert_not policy.unblock?, "Regular admin should not be able to unblock users"
    end

    # ========================================
    # Super Admin Tests
    # ========================================

    test "super_admin can view users index" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.index?, "Super admin should be able to view users index"
    end

    test "super_admin can view user details" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.show?, "Super admin should be able to view user details"
    end

    test "super_admin can edit user" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.edit?, "Super admin should be able to edit user"
      assert policy.update?, "Super admin should be able to update user"
    end

    test "super_admin can create users" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.new?, "Super admin should be able to access new user form"
      assert policy.create?, "Super admin should be able to create users"
    end

    test "super_admin can delete other users" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.destroy?, "Super admin should be able to delete other users"
    end

    test "super_admin cannot delete themselves" do
      policy = Admin::UserPolicy.new(@super_admin_user, @super_admin_user)
      assert_not policy.destroy?, "Super admin should not be able to delete themselves"
    end

    test "super_admin can change user roles" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.change_role?, "Super admin should be able to change user roles"
    end

    test "super_admin can suspend users" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.suspend?, "Super admin should be able to suspend users"
      assert policy.unsuspend?, "Super admin should be able to unsuspend users"
    end

    test "super_admin can block users" do
      policy = Admin::UserPolicy.new(@super_admin_user, @patient_user)
      assert policy.block?, "Super admin should be able to block users"
      assert policy.unblock?, "Super admin should be able to unblock users"
    end

    test "non-admin cannot access user management" do
      policy = Admin::UserPolicy.new(@provider_user, @patient_user)
      assert_not policy.index?, "Non-admin should not access users index"
      assert_not policy.show?, "Non-admin should not view user details"
      assert_not policy.update?, "Non-admin should not update users"
      assert_not policy.destroy?, "Non-admin should not delete users"
      assert_not policy.change_role?, "Non-admin should not change roles"
    end

    # ========================================
    # Scope Tests
    # ========================================

    test "admin scope resolves to all users" do
      scope = Admin::UserPolicy::Scope.new(@admin_user, User.all)
      assert_equal User.count, scope.resolve.count, "Admin scope should return all users"
    end

    test "super_admin scope resolves to all users" do
      scope = Admin::UserPolicy::Scope.new(@super_admin_user, User.all)
      assert_equal User.count, scope.resolve.count, "Super admin scope should return all users"
    end

    test "non-admin scope resolves to none" do
      scope = Admin::UserPolicy::Scope.new(@provider_user, User.all)
      assert_equal 0, scope.resolve.count, "Non-admin scope should return no users"
    end
  end
end
