require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @provider_user = users(:provider_user)
    @patient_user = users(:patient_user)
  end

  test "should get index as admin" do
    sign_in @admin_user
    get admin_root_path
    assert_response :success
    # Dashboard uses content_for :admin_page_title, check for page title in layout
    assert_match /Platform Overview/i, response.body
  end

  test "should not get index as provider" do
    sign_in @provider_user
    get admin_root_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "should not get index as patient" do
    sign_in @patient_user
    get admin_root_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "should not get index as guest" do
    get admin_root_path
    assert_redirected_to new_user_session_path
  end

  test "dashboard should display user metrics" do
    sign_in @admin_user
    get admin_root_path
    assert_response :success

    # Check for user count metrics (metric cards use bg-white rounded-lg shadow p-6)
    assert_select "div.bg-white.rounded-lg.shadow", minimum: 1
    assert_match /Total Users/i, response.body
    assert_match /Providers/i, response.body
    assert_match /Patients/i, response.body
  end

  test "dashboard should display appointment metrics" do
    sign_in @admin_user
    get admin_root_path
    assert_response :success

    # Check for appointment metrics
    assert_match /Appointments/i, response.body
    assert_match /Scheduled/i, response.body
  end

  test "dashboard should display payment metrics" do
    sign_in @admin_user
    get admin_root_path
    assert_response :success

    # Check for payment/revenue metrics
    assert_match /Revenue/i, response.body
  end

  test "dashboard should display quick links to management sections" do
    sign_in @admin_user
    get admin_root_path
    assert_response :success

    # Check for navigation links
    assert_select "a[href=?]", admin_users_path
    assert_select "a[href=?]", admin_provider_profiles_path
    assert_select "a[href=?]", admin_appointments_path
    assert_select "a[href=?]", admin_payments_path
  end
end
