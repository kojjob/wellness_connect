require "test_helper"

module Admin
  class AppointmentPolicyTest < ActiveSupport::TestCase
    def setup
      @admin_user = users(:admin_user)
      @provider_user = users(:provider_user)
      @appointment = appointments(:appointment_one)
    end

    test "admin can view appointments index" do
      policy = Admin::AppointmentPolicy.new(@admin_user, @appointment)
      assert policy.index?, "Admin should be able to view appointments index"
    end

    test "admin can view appointment details" do
      policy = Admin::AppointmentPolicy.new(@admin_user, @appointment)
      assert policy.show?, "Admin should be able to view appointment details"
    end

    test "admin cannot create appointments" do
      policy = Admin::AppointmentPolicy.new(@admin_user, Appointment.new)
      assert_not policy.create?, "Admin should not be able to create appointments"
      assert_not policy.new?, "Admin should not be able to access new appointment form"
    end

    test "admin cannot edit appointments" do
      policy = Admin::AppointmentPolicy.new(@admin_user, @appointment)
      assert_not policy.edit?, "Admin should not be able to edit appointments"
      assert_not policy.update?, "Admin should not be able to update appointments"
    end

    test "admin cannot delete appointments" do
      policy = Admin::AppointmentPolicy.new(@admin_user, @appointment)
      assert_not policy.destroy?, "Admin should not be able to delete appointments"
    end

    test "non-admin cannot access appointments" do
      policy = Admin::AppointmentPolicy.new(@provider_user, @appointment)
      assert_not policy.index?, "Non-admin should not access appointments index"
      assert_not policy.show?, "Non-admin should not view appointment details"
    end

    # Test Scope
    test "admin scope resolves to all appointments" do
      scope = Admin::AppointmentPolicy::Scope.new(@admin_user, Appointment.all)
      assert_equal Appointment.count, scope.resolve.count, "Admin scope should return all appointments"
    end

    test "non-admin scope resolves to none" do
      scope = Admin::AppointmentPolicy::Scope.new(@provider_user, Appointment.all)
      assert_equal 0, scope.resolve.count, "Non-admin scope should return no appointments"
    end
  end
end
