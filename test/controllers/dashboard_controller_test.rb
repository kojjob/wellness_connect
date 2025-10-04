require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @patient = users(:patient_user)
    @admin = users(:admin_user)
  end

  # Access Control Tests
  test "should redirect to login when not authenticated" do
    get dashboard_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect to root when patient tries to access dashboard" do
    sign_in @patient
    get dashboard_url
    assert_redirected_to root_url
  end

  test "should redirect to root when admin tries to access dashboard" do
    sign_in @admin
    get dashboard_url
    assert_redirected_to root_url
  end

  test "should get dashboard when provider is authenticated" do
    sign_in @provider
    get dashboard_url
    assert_response :success
  end

  # Content Display Tests
  test "should display provider profile information" do
    sign_in @provider
    get dashboard_url
    assert_select "h1", text: /Dashboard/
    assert_select "p", text: /#{@provider.first_name} #{@provider.last_name}/
  end

  test "should display provider's services" do
    sign_in @provider
    get dashboard_url

    # Should display services
    @provider_profile.services.each do |service|
      assert_select "a[href=?]", provider_profile_service_path(@provider_profile, service), text: service.name
    end
  end

  test "should display link to add new service" do
    sign_in @provider
    get dashboard_url
    assert_select "a[href=?]", new_provider_profile_service_path(@provider_profile), text: /Add.*Service/i
  end

  test "should display provider's availabilities" do
    sign_in @provider
    get dashboard_url

    # Should display availabilities
    assert_select "a[href=?]", provider_profile_availabilities_path(@provider_profile)
  end

  test "should display link to add new availability" do
    sign_in @provider
    get dashboard_url
    assert_select "a[href=?]", new_provider_profile_availability_path(@provider_profile), text: /Add.*Availability/i
  end

  test "should display provider statistics" do
    sign_in @provider
    get dashboard_url

    # Should show service count
    assert_select "div", text: /#{@provider_profile.services.count}.*Service/i

    # Should show availability count
    assert_select "div", text: /#{@provider_profile.availabilities.count}.*Slot/i
  end

  test "should display edit profile link" do
    sign_in @provider
    get dashboard_url
    assert_select "a[href=?]", edit_provider_profile_path(@provider_profile), text: /Edit.*Profile/i
  end
end
