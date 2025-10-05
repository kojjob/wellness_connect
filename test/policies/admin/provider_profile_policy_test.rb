require "test_helper"

module Admin
  class ProviderProfilePolicyTest < ActiveSupport::TestCase
    def setup
      @admin_user = users(:admin_user)
      @provider_user = users(:provider_user)
      @provider_profile = provider_profiles(:provider_profile_one)
    end

    test "admin can view provider profiles index" do
      policy = Admin::ProviderProfilePolicy.new(@admin_user, @provider_profile)
      assert policy.index?, "Admin should be able to view provider profiles index"
    end

    test "admin can view provider profile details" do
      policy = Admin::ProviderProfilePolicy.new(@admin_user, @provider_profile)
      assert policy.show?, "Admin should be able to view provider profile details"
    end

    test "admin can edit provider profiles" do
      policy = Admin::ProviderProfilePolicy.new(@admin_user, @provider_profile)
      assert policy.edit?, "Admin should be able to edit provider profiles"
      assert policy.update?, "Admin should be able to update provider profiles"
    end

    test "admin cannot create provider profiles" do
      policy = Admin::ProviderProfilePolicy.new(@admin_user, ProviderProfile.new)
      assert_not policy.create?, "Admin should not be able to create provider profiles"
      assert_not policy.new?, "Admin should not be able to access new provider profile form"
    end

    test "admin cannot delete provider profiles" do
      policy = Admin::ProviderProfilePolicy.new(@admin_user, @provider_profile)
      assert_not policy.destroy?, "Admin should not be able to delete provider profiles"
    end

    test "non-admin cannot access provider profiles" do
      policy = Admin::ProviderProfilePolicy.new(@provider_user, @provider_profile)
      assert_not policy.index?, "Non-admin should not access provider profiles index"
      assert_not policy.show?, "Non-admin should not view provider profile details"
      assert_not policy.update?, "Non-admin should not update provider profiles"
    end

    # Test Scope
    test "admin scope resolves to all provider profiles" do
      scope = Admin::ProviderProfilePolicy::Scope.new(@admin_user, ProviderProfile.all)
      assert_equal ProviderProfile.count, scope.resolve.count, "Admin scope should return all provider profiles"
    end

    test "non-admin scope resolves to none" do
      scope = Admin::ProviderProfilePolicy::Scope.new(@provider_user, ProviderProfile.all)
      assert_equal 0, scope.resolve.count, "Non-admin scope should return no provider profiles"
    end
  end
end
