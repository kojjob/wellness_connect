require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @patient = users(:patient_user)
    @service = services(:service_one)
    @another_provider = users(:provider_user_two)
    @another_provider_profile = provider_profiles(:provider_profile_two)
  end

  # Index tests
  test "should get index when authenticated" do
    sign_in @patient
    get provider_profile_services_url(@provider_profile)
    assert_response :success
  end

  test "should not get index when not authenticated" do
    get provider_profile_services_url(@provider_profile)
    assert_redirected_to new_user_session_url
  end

  # Show tests
  test "should show service when authenticated" do
    sign_in @patient
    get provider_profile_service_url(@provider_profile, @service)
    assert_response :success
  end

  test "should not show service when not authenticated" do
    get provider_profile_service_url(@provider_profile, @service)
    assert_redirected_to new_user_session_url
  end

  # New tests
  test "should get new when provider owns profile" do
    sign_in @provider
    get new_provider_profile_service_url(@provider_profile)
    assert_response :success
  end

  test "should not get new when user is not provider" do
    sign_in @patient
    get new_provider_profile_service_url(@provider_profile)
    assert_redirected_to root_url
  end

  test "should not get new when provider does not own profile" do
    sign_in @another_provider
    get new_provider_profile_service_url(@provider_profile)
    assert_redirected_to root_url
  end

  # Create tests
  test "should create service when provider owns profile" do
    sign_in @provider
    assert_difference("Service.count", 1) do
      post provider_profile_services_url(@provider_profile), params: {
        service: {
          name: "New Service",
          description: "Test description",
          duration_minutes: 45,
          price: 100.0,
          is_active: true
        }
      }
    end
    assert_redirected_to provider_profile_service_url(@provider_profile, Service.last)
  end

  test "should not create service when user is not provider" do
    sign_in @patient
    assert_no_difference("Service.count") do
      post provider_profile_services_url(@provider_profile), params: {
        service: {
          name: "New Service",
          description: "Test description",
          duration_minutes: 45,
          price: 100.0,
          is_active: true
        }
      }
    end
    assert_redirected_to root_url
  end

  test "should not create service when provider does not own profile" do
    sign_in @another_provider
    assert_no_difference("Service.count") do
      post provider_profile_services_url(@provider_profile), params: {
        service: {
          name: "New Service",
          description: "Test description",
          duration_minutes: 45,
          price: 100.0,
          is_active: true
        }
      }
    end
    assert_redirected_to root_url
  end

  test "should not create service with invalid attributes" do
    sign_in @provider
    assert_no_difference("Service.count") do
      post provider_profile_services_url(@provider_profile), params: {
        service: {
          name: "",
          description: "",
          duration_minutes: nil,
          price: nil
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit tests
  test "should get edit when provider owns profile" do
    sign_in @provider
    get edit_provider_profile_service_url(@provider_profile, @service)
    assert_response :success
  end

  test "should not get edit when user is not provider" do
    sign_in @patient
    get edit_provider_profile_service_url(@provider_profile, @service)
    assert_redirected_to root_url
  end

  test "should not get edit when provider does not own profile" do
    sign_in @another_provider
    get edit_provider_profile_service_url(@provider_profile, @service)
    assert_redirected_to root_url
  end

  # Update tests
  test "should update service when provider owns profile" do
    sign_in @provider
    patch provider_profile_service_url(@provider_profile, @service), params: {
      service: {
        name: "Updated Service Name"
      }
    }
    assert_redirected_to provider_profile_service_url(@provider_profile, @service)
    @service.reload
    assert_equal "Updated Service Name", @service.name
  end

  test "should not update service when user is not provider" do
    sign_in @patient
    patch provider_profile_service_url(@provider_profile, @service), params: {
      service: {
        name: "Updated Service Name"
      }
    }
    assert_redirected_to root_url
    @service.reload
    assert_not_equal "Updated Service Name", @service.name
  end

  test "should not update service when provider does not own profile" do
    sign_in @another_provider
    patch provider_profile_service_url(@provider_profile, @service), params: {
      service: {
        name: "Updated Service Name"
      }
    }
    assert_redirected_to root_url
    @service.reload
    assert_not_equal "Updated Service Name", @service.name
  end

  test "should not update service with invalid attributes" do
    sign_in @provider
    patch provider_profile_service_url(@provider_profile, @service), params: {
      service: {
        name: "",
        price: nil
      }
    }
    assert_response :unprocessable_entity
    @service.reload
    assert_not_equal "", @service.name
  end

  # Destroy tests
  test "should destroy service when provider owns profile" do
    sign_in @provider
    assert_difference("Service.count", -1) do
      delete provider_profile_service_url(@provider_profile, @service)
    end
    assert_redirected_to provider_profile_services_url(@provider_profile)
  end

  test "should not destroy service when user is not provider" do
    sign_in @patient
    assert_no_difference("Service.count") do
      delete provider_profile_service_url(@provider_profile, @service)
    end
    assert_redirected_to root_url
  end

  test "should not destroy service when provider does not own profile" do
    sign_in @another_provider
    assert_no_difference("Service.count") do
      delete provider_profile_service_url(@provider_profile, @service)
    end
    assert_redirected_to root_url
  end
end
