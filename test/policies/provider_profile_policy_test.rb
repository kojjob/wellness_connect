require "test_helper"

class ProviderProfilePolicyTest < ActiveSupport::TestCase
  setup do
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @other_provider = users(:provider_user_two)
    @patient = users(:patient_user)
  end

  test "scope returns all provider profiles" do
    scope = ProviderProfilePolicy::Scope.new(@provider, ProviderProfile).resolve
    assert_equal ProviderProfile.count, scope.count
  end

  test "index allows all authenticated users" do
    # Provider can index
    assert ProviderProfilePolicy.new(@provider, ProviderProfile).index?
    # Patient can index
    assert ProviderProfilePolicy.new(@patient, ProviderProfile).index?
  end

  test "show allows all authenticated users" do
    # Provider can show
    assert ProviderProfilePolicy.new(@provider, @provider_profile).show?
    # Patient can show
    assert ProviderProfilePolicy.new(@patient, @provider_profile).show?
  end

  test "create only allows providers" do
    # Provider can create
    assert ProviderProfilePolicy.new(@provider, ProviderProfile.new).create?
    # Patient cannot create
    assert_not ProviderProfilePolicy.new(@patient, ProviderProfile.new).create?
  end

  test "new only allows providers" do
    # Provider can access new
    assert ProviderProfilePolicy.new(@provider, ProviderProfile.new).new?
    # Patient cannot access new
    assert_not ProviderProfilePolicy.new(@patient, ProviderProfile.new).new?
  end

  test "update only allows profile owner" do
    # Profile owner can update
    assert ProviderProfilePolicy.new(@provider, @provider_profile).update?
    # Other provider cannot update
    assert_not ProviderProfilePolicy.new(@other_provider, @provider_profile).update?
    # Patient cannot update
    assert_not ProviderProfilePolicy.new(@patient, @provider_profile).update?
  end

  test "edit only allows profile owner" do
    # Profile owner can edit
    assert ProviderProfilePolicy.new(@provider, @provider_profile).edit?
    # Other provider cannot edit
    assert_not ProviderProfilePolicy.new(@other_provider, @provider_profile).edit?
    # Patient cannot edit
    assert_not ProviderProfilePolicy.new(@patient, @provider_profile).edit?
  end

  test "destroy only allows profile owner" do
    # Profile owner can destroy
    assert ProviderProfilePolicy.new(@provider, @provider_profile).destroy?
    # Other provider cannot destroy
    assert_not ProviderProfilePolicy.new(@other_provider, @provider_profile).destroy?
    # Patient cannot destroy
    assert_not ProviderProfilePolicy.new(@patient, @provider_profile).destroy?
  end
end
