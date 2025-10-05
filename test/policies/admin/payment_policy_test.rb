require "test_helper"

module Admin
  class PaymentPolicyTest < ActiveSupport::TestCase
    def setup
      @admin_user = users(:admin_user)
      @provider_user = users(:provider_user)
      @payment = payments(:payment_one)
    end

    test "admin can view payments index" do
      policy = Admin::PaymentPolicy.new(@admin_user, @payment)
      assert policy.index?, "Admin should be able to view payments index"
    end

    test "admin can view payment details" do
      policy = Admin::PaymentPolicy.new(@admin_user, @payment)
      assert policy.show?, "Admin should be able to view payment details"
    end

    test "admin cannot create payments" do
      policy = Admin::PaymentPolicy.new(@admin_user, Payment.new)
      assert_not policy.create?, "Admin should not be able to create payments"
      assert_not policy.new?, "Admin should not be able to access new payment form"
    end

    test "admin cannot edit payments" do
      policy = Admin::PaymentPolicy.new(@admin_user, @payment)
      assert_not policy.edit?, "Admin should not be able to edit payments"
      assert_not policy.update?, "Admin should not be able to update payments"
    end

    test "admin cannot delete payments" do
      policy = Admin::PaymentPolicy.new(@admin_user, @payment)
      assert_not policy.destroy?, "Admin should not be able to delete payments"
    end

    test "non-admin cannot access payments" do
      policy = Admin::PaymentPolicy.new(@provider_user, @payment)
      assert_not policy.index?, "Non-admin should not access payments index"
      assert_not policy.show?, "Non-admin should not view payment details"
    end

    # Test Scope
    test "admin scope resolves to all payments" do
      scope = Admin::PaymentPolicy::Scope.new(@admin_user, Payment.all)
      assert_equal Payment.count, scope.resolve.count, "Admin scope should return all payments"
    end

    test "non-admin scope resolves to none" do
      scope = Admin::PaymentPolicy::Scope.new(@provider_user, Payment.all)
      assert_equal 0, scope.resolve.count, "Non-admin scope should return no payments"
    end
  end
end
