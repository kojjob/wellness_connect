require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:patient_user)
  end

  # ========================================
  # Status Query Method Tests
  # ========================================

  test "active? returns true for users without suspended_at or blocked_at" do
    assert @user.active?
  end

  test "active? returns false for suspended users" do
    @user.update(suspended_at: Time.current)
    assert_not @user.active?
  end

  test "active? returns false for blocked users" do
    @user.update(blocked_at: Time.current)
    assert_not @user.active?
  end

  test "suspended? returns false by default" do
    assert_not @user.suspended?
  end

  test "suspended? returns true when suspended_at is set" do
    @user.update(suspended_at: Time.current)
    assert @user.suspended?
  end

  test "blocked? returns false by default" do
    assert_not @user.blocked?
  end

  test "blocked? returns true when blocked_at is set" do
    @user.update(blocked_at: Time.current)
    assert @user.blocked?
  end

  test "inactive? returns false for active users" do
    assert_not @user.inactive?
  end

  test "inactive? returns true for suspended users" do
    @user.update(suspended_at: Time.current)
    assert @user.inactive?
  end

  test "inactive? returns true for blocked users" do
    @user.update(blocked_at: Time.current)
    assert @user.inactive?
  end

  # ========================================
  # Status Change Method Tests
  # ========================================

  test "suspend! sets suspended_at timestamp" do
    assert_nil @user.suspended_at
    @user.suspend!
    assert_not_nil @user.suspended_at
    assert @user.suspended?
  end

  test "suspend! can accept a reason" do
    @user.suspend!("Policy violation")
    assert_equal "Policy violation", @user.status_reason
  end

  test "unsuspend! clears suspended_at timestamp" do
    @user.update(suspended_at: Time.current, status_reason: "Test")
    @user.unsuspend!
    assert_nil @user.suspended_at
    assert_nil @user.status_reason
    assert @user.active?
  end

  test "block! sets blocked_at timestamp" do
    assert_nil @user.blocked_at
    @user.block!
    assert_not_nil @user.blocked_at
    assert @user.blocked?
  end

  test "block! can accept a reason" do
    @user.block!("Fraudulent activity")
    assert_equal "Fraudulent activity", @user.status_reason
  end

  test "unblock! clears blocked_at timestamp" do
    @user.update(blocked_at: Time.current, status_reason: "Test")
    @user.unblock!
    assert_nil @user.blocked_at
    assert_nil @user.status_reason
    assert @user.active?
  end

  # ========================================
  # Scope Tests
  # ========================================

  test "active scope returns only active users" do
    suspended_user = users(:provider_user)
    suspended_user.update(suspended_at: Time.current)

    active_users = User.active

    assert_includes active_users, @user
    assert_not_includes active_users, suspended_user
  end

  test "suspended scope returns only suspended users" do
    @user.suspend!

    suspended_users = User.suspended

    assert_includes suspended_users, @user
  end

  test "blocked scope returns only blocked users" do
    @user.block!

    blocked_users = User.blocked

    assert_includes blocked_users, @user
  end

  test "inactive scope returns suspended and blocked users" do
    suspended_user = users(:provider_user)
    suspended_user.suspend!

    @user.block!

    inactive_users = User.inactive

    assert_includes inactive_users, @user
    assert_includes inactive_users, suspended_user
  end

  test "search scope finds users by first name" do
    results = User.search(@user.first_name)
    assert_includes results, @user
  end

  test "search scope finds users by last name" do
    results = User.search(@user.last_name)
    assert_includes results, @user
  end

  test "search scope finds users by email" do
    results = User.search(@user.email)
    assert_includes results, @user
  end

  test "search scope is case insensitive" do
    results = User.search(@user.email.upcase)
    assert_includes results, @user
  end

  test "search scope returns all users when query is blank" do
    results = User.search("")
    assert_equal User.count, results.count
  end

  # ========================================
  # Helper Method Tests
  # ========================================

  test "status returns active for active users" do
    assert_equal "active", @user.status
  end

  test "status returns suspended for suspended users" do
    @user.suspend!
    assert_equal "suspended", @user.status
  end

  test "status returns blocked for blocked users" do
    @user.block!
    assert_equal "blocked", @user.status
  end

  test "status_badge_class returns correct CSS class for active users" do
    assert_equal "bg-green-100 text-green-800", @user.status_badge_class
  end

  test "status_badge_class returns correct CSS class for suspended users" do
    @user.suspend!
    assert_equal "bg-yellow-100 text-yellow-800", @user.status_badge_class
  end

  test "status_badge_class returns correct CSS class for blocked users" do
    @user.block!
    assert_equal "bg-red-100 text-red-800", @user.status_badge_class
  end

  # ========================================
  # Devise Integration Tests
  # ========================================

  test "active_for_authentication? returns true for active users" do
    assert @user.active_for_authentication?
  end

  test "active_for_authentication? returns false for suspended users" do
    @user.update(suspended_at: Time.current)
    assert_not @user.active_for_authentication?
  end

  test "active_for_authentication? returns false for blocked users" do
    @user.update(blocked_at: Time.current)
    assert_not @user.active_for_authentication?
  end

  test "inactive_message returns :suspended for suspended users" do
    @user.suspend!
    assert_equal :suspended, @user.inactive_message
  end

  test "inactive_message returns :blocked for blocked users" do
    @user.block!
    assert_equal :blocked, @user.inactive_message
  end
end
