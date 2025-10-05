require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  # ========================================
  # Admin Permissions Tests
  # ========================================

  test "admin can view all users (index)" do
    admin = users(:admin_user)
    policy = UserPolicy.new(admin, User)
    assert policy.index?, "Admin should be able to view all users"
  end

  test "admin can view any user (show)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(admin, other_user)
    assert policy.show?, "Admin should be able to view any user"
  end

  test "admin can create new users (create)" do
    admin = users(:admin_user)
    policy = UserPolicy.new(admin, User.new)
    assert policy.create?, "Admin should be able to create users"
  end

  test "admin can create new users (new)" do
    admin = users(:admin_user)
    policy = UserPolicy.new(admin, User.new)
    assert policy.new?, "Admin should be able to access new user form"
  end

  test "admin can edit any user (edit)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(admin, other_user)
    assert policy.edit?, "Admin should be able to edit any user"
  end

  test "admin can update any user (update)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(admin, other_user)
    assert policy.update?, "Admin should be able to update any user"
  end

  test "admin can delete any user (destroy)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(admin, other_user)
    assert policy.destroy?, "Admin should be able to delete any user"
  end

  test "admin can suspend any user (suspend)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(admin, other_user)
    assert policy.suspend?, "Admin should be able to suspend any user"
  end

  test "admin can unsuspend any user (unsuspend)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    other_user.update(suspended_at: Time.current)
    policy = UserPolicy.new(admin, other_user)
    assert policy.unsuspend?, "Admin should be able to unsuspend any user"
  end

  test "admin can block any user (block)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(admin, other_user)
    assert policy.block?, "Admin should be able to block any user"
  end

  test "admin can unblock any user (unblock)" do
    admin = users(:admin_user)
    other_user = users(:patient_user)
    other_user.update(blocked_at: Time.current)
    policy = UserPolicy.new(admin, other_user)
    assert policy.unblock?, "Admin should be able to unblock any user"
  end

  # ========================================
  # Provider Permissions Tests
  # ========================================

  test "provider cannot view all users (index)" do
    provider = users(:provider_user)
    policy = UserPolicy.new(provider, User)
    assert_not policy.index?, "Provider should not be able to view all users"
  end

  test "provider can view their own profile (show)" do
    provider = users(:provider_user)
    policy = UserPolicy.new(provider, provider)
    assert policy.show?, "Provider should be able to view their own profile"
  end

  test "provider cannot view other users (show)" do
    provider = users(:provider_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(provider, other_user)
    assert_not policy.show?, "Provider should not be able to view other users"
  end

  test "provider cannot create new users (create)" do
    provider = users(:provider_user)
    policy = UserPolicy.new(provider, User.new)
    assert_not policy.create?, "Provider should not be able to create users"
  end

  test "provider can edit their own profile (edit)" do
    provider = users(:provider_user)
    policy = UserPolicy.new(provider, provider)
    assert policy.edit?, "Provider should be able to edit their own profile"
  end

  test "provider cannot edit other users (edit)" do
    provider = users(:provider_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(provider, other_user)
    assert_not policy.edit?, "Provider should not be able to edit other users"
  end

  test "provider can update their own profile (update)" do
    provider = users(:provider_user)
    policy = UserPolicy.new(provider, provider)
    assert policy.update?, "Provider should be able to update their own profile"
  end

  test "provider cannot update other users (update)" do
    provider = users(:provider_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(provider, other_user)
    assert_not policy.update?, "Provider should not be able to update other users"
  end

  test "provider cannot delete users (destroy)" do
    provider = users(:provider_user)
    policy = UserPolicy.new(provider, provider)
    assert_not policy.destroy?, "Provider should not be able to delete users"
  end

  test "provider cannot suspend users (suspend)" do
    provider = users(:provider_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(provider, other_user)
    assert_not policy.suspend?, "Provider should not be able to suspend users"
  end

  test "provider cannot unsuspend users (unsuspend)" do
    provider = users(:provider_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(provider, other_user)
    assert_not policy.unsuspend?, "Provider should not be able to unsuspend users"
  end

  test "provider cannot block users (block)" do
    provider = users(:provider_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(provider, other_user)
    assert_not policy.block?, "Provider should not be able to block users"
  end

  test "provider cannot unblock users (unblock)" do
    provider = users(:provider_user)
    other_user = users(:patient_user)
    policy = UserPolicy.new(provider, other_user)
    assert_not policy.unblock?, "Provider should not be able to unblock users"
  end

  # ========================================
  # Patient (Client) Permissions Tests
  # ========================================

  test "patient cannot view all users (index)" do
    patient = users(:patient_user)
    policy = UserPolicy.new(patient, User)
    assert_not policy.index?, "Patient should not be able to view all users"
  end

  test "patient can view their own profile (show)" do
    patient = users(:patient_user)
    policy = UserPolicy.new(patient, patient)
    assert policy.show?, "Patient should be able to view their own profile"
  end

  test "patient cannot view other users (show)" do
    patient = users(:patient_user)
    other_user = users(:provider_user)
    policy = UserPolicy.new(patient, other_user)
    assert_not policy.show?, "Patient should not be able to view other users"
  end

  test "patient cannot create new users (create)" do
    patient = users(:patient_user)
    policy = UserPolicy.new(patient, User.new)
    assert_not policy.create?, "Patient should not be able to create users"
  end

  test "patient can edit their own profile (edit)" do
    patient = users(:patient_user)
    policy = UserPolicy.new(patient, patient)
    assert policy.edit?, "Patient should be able to edit their own profile"
  end

  test "patient cannot edit other users (edit)" do
    patient = users(:patient_user)
    other_user = users(:provider_user)
    policy = UserPolicy.new(patient, other_user)
    assert_not policy.edit?, "Patient should not be able to edit other users"
  end

  test "patient can update their own profile (update)" do
    patient = users(:patient_user)
    policy = UserPolicy.new(patient, patient)
    assert policy.update?, "Patient should be able to update their own profile"
  end

  test "patient cannot update other users (update)" do
    patient = users(:patient_user)
    other_user = users(:provider_user)
    policy = UserPolicy.new(patient, other_user)
    assert_not policy.update?, "Patient should not be able to update other users"
  end

  test "patient cannot delete users (destroy)" do
    patient = users(:patient_user)
    policy = UserPolicy.new(patient, patient)
    assert_not policy.destroy?, "Patient should not be able to delete users"
  end

  test "patient cannot suspend users (suspend)" do
    patient = users(:patient_user)
    other_user = users(:provider_user)
    policy = UserPolicy.new(patient, other_user)
    assert_not policy.suspend?, "Patient should not be able to suspend users"
  end

  test "patient cannot unsuspend users (unsuspend)" do
    patient = users(:patient_user)
    other_user = users(:provider_user)
    policy = UserPolicy.new(patient, other_user)
    assert_not policy.unsuspend?, "Patient should not be able to unsuspend users"
  end

  test "patient cannot block users (block)" do
    patient = users(:patient_user)
    other_user = users(:provider_user)
    policy = UserPolicy.new(patient, other_user)
    assert_not policy.block?, "Patient should not be able to block users"
  end

  test "patient cannot unblock users (unblock)" do
    patient = users(:patient_user)
    other_user = users(:provider_user)
    policy = UserPolicy.new(patient, other_user)
    assert_not policy.unblock?, "Patient should not be able to unblock users"
  end

  # ========================================
  # Guest (Not Signed In) Permissions Tests
  # ========================================

  test "guest cannot view all users (index)" do
    policy = UserPolicy.new(nil, User)
    assert_not policy.index?, "Guest should not be able to view all users"
  end

  test "guest cannot view any user (show)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.show?, "Guest should not be able to view any user"
  end

  test "guest cannot create users (create)" do
    policy = UserPolicy.new(nil, User.new)
    assert_not policy.create?, "Guest should not be able to create users"
  end

  test "guest cannot edit users (edit)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.edit?, "Guest should not be able to edit users"
  end

  test "guest cannot update users (update)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.update?, "Guest should not be able to update users"
  end

  test "guest cannot delete users (destroy)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.destroy?, "Guest should not be able to delete users"
  end

  test "guest cannot suspend users (suspend)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.suspend?, "Guest should not be able to suspend users"
  end

  test "guest cannot unsuspend users (unsuspend)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.unsuspend?, "Guest should not be able to unsuspend users"
  end

  test "guest cannot block users (block)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.block?, "Guest should not be able to block users"
  end

  test "guest cannot unblock users (unblock)" do
    policy = UserPolicy.new(nil, users(:patient_user))
    assert_not policy.unblock?, "Guest should not be able to unblock users"
  end

  # ========================================
  # Scope Tests
  # ========================================

  test "admin scope returns all users" do
    admin = users(:admin_user)
    scope = UserPolicy::Scope.new(admin, User.all).resolve
    assert_equal User.count, scope.count, "Admin scope should return all users"
  end

  test "provider scope returns only themselves" do
    provider = users(:provider_user)
    scope = UserPolicy::Scope.new(provider, User.all).resolve
    assert_equal 1, scope.count, "Provider scope should return only themselves"
    assert_includes scope, provider, "Provider scope should include themselves"
  end

  test "patient scope returns only themselves" do
    patient = users(:patient_user)
    scope = UserPolicy::Scope.new(patient, User.all).resolve
    assert_equal 1, scope.count, "Patient scope should return only themselves"
    assert_includes scope, patient, "Patient scope should include themselves"
  end

  test "guest scope returns empty collection" do
    scope = UserPolicy::Scope.new(nil, User.all).resolve
    assert_equal 0, scope.count, "Guest scope should return no users"
  end
end
