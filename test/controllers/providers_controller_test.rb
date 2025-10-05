require "test_helper"

class ProvidersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @another_provider = users(:provider_user_two)
    @another_provider_profile = provider_profiles(:provider_profile_two)
    @patient = users(:patient_user)
  end

  # Index Tests
  test "should get index without authentication" do
    get providers_url
    assert_response :success
  end

  test "should get index when authenticated as patient" do
    sign_in @patient
    get providers_url
    assert_response :success
  end

  test "should get index when authenticated as provider" do
    sign_in @provider
    get providers_url
    assert_response :success
  end

  test "should display all active provider profiles on index" do
    get providers_url
    assert_response :success

    # Should display first provider
    assert_select "div", text: /#{@provider.first_name} #{@provider.last_name}/
    assert_select "p", text: /#{@provider_profile.specialty}/

    # Should display second provider
    assert_select "div", text: /#{@another_provider.first_name} #{@another_provider.last_name}/
    assert_select "p", text: /#{@another_provider_profile.specialty}/
  end

  test "should display link to view provider profile" do
    get providers_url
    assert_select "a[href=?]", provider_profile_path(@provider_profile)
    assert_select "a[href=?]", provider_profile_path(@another_provider_profile)
  end

  # Search/Filter Tests
  test "should filter providers by specialty" do
    get providers_url, params: { specialty: @provider_profile.specialty }
    assert_response :success

    # Should display matching provider
    assert_select "div", text: /#{@provider.first_name} #{@provider.last_name}/

    # Should not display non-matching provider if different specialty
    if @provider_profile.specialty != @another_provider_profile.specialty
      assert_select "div", { text: /#{@another_provider.first_name} #{@another_provider.last_name}/, count: 0 }
    end
  end

  test "should search providers by name" do
    get providers_url, params: { search: @provider.first_name }
    assert_response :success

    # Should display matching provider
    assert_select "div", text: /#{@provider.first_name}/
  end

  # Show Tests (Individual Provider Profile)
  test "should show provider profile without authentication" do
    get provider_profile_url(@provider_profile)
    assert_response :success
  end

  test "should show provider profile when authenticated" do
    sign_in @patient
    get provider_profile_url(@provider_profile)
    assert_response :success
  end

  test "should display provider information on show page" do
    get provider_profile_url(@provider_profile)
    assert_response :success

    # Provider details
    assert_select "h1", text: /#{@provider.first_name} #{@provider.last_name}/
    assert_select "p", text: /#{@provider_profile.specialty}/
    assert_select "p", text: /#{@provider_profile.bio}/
    assert_select "p", text: /#{@provider_profile.credentials}/
  end

  test "should display provider's services on show page" do
    get provider_profile_url(@provider_profile)
    assert_response :success

    # Should show services
    @provider_profile.services.each do |service|
      assert_select "div", text: /#{service.name}/
    end
  end

  test "should display provider's available slots on show page" do
    get provider_profile_url(@provider_profile)
    assert_response :success

    # Should show availabilities section
    assert_select "h2", text: /Available/i
  end

  test "should display consultation rate on show page" do
    get provider_profile_url(@provider_profile)
    assert_response :success

    assert_select "div", text: /\$#{@provider_profile.consultation_rate}/
  end

  # Error Handling Tests
  test "should handle invalid provider profile id" do
    get provider_profile_url(id: 99999)
    assert_response :not_found
  end
end
