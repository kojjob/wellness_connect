require "test_helper"

class ProviderProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider_user = users(:provider_user)
    @patient_user = users(:patient_user)
    @provider_profile = provider_profiles(:provider_profile_one)
  end

  # Index tests - Public browsing allowed
  test "should get index without authentication" do
    get provider_profiles_url
    assert_response :success
  end

  test "should get index when authenticated as patient" do
    sign_in @patient_user
    get provider_profiles_url
    assert_response :success
  end

  test "should get index when authenticated as provider" do
    sign_in @provider_user
    get provider_profiles_url
    assert_response :success
  end

  test "should display all active provider profiles on index" do
    get provider_profiles_url
    assert_response :success

    # Should display provider information
    assert_select "div", text: /#{@provider_user.first_name} #{@provider_user.last_name}/
    assert_select "p", text: /#{@provider_profile.specialty}/
  end

  test "should display link to view provider profile" do
    get provider_profiles_url
    assert_select "a[href=?]", provider_profile_path(@provider_profile)
  end

  test "should filter providers by specialty" do
    get provider_profiles_url, params: { specialty: @provider_profile.specialty }
    assert_response :success

    # Should display matching provider
    assert_select "div", text: /#{@provider_user.first_name} #{@provider_user.last_name}/
  end

  test "should search providers by name" do
    get provider_profiles_url, params: { search: @provider_user.first_name }
    assert_response :success

    # Should display matching provider
    assert_select "div", text: /#{@provider_user.first_name}/
  end

  # Show tests - Public viewing allowed
  test "should show provider profile without authentication" do
    get provider_profile_url(@provider_profile)
    assert_response :success
  end

  test "should show provider profile when authenticated" do
    sign_in @patient_user
    get provider_profile_url(@provider_profile)
    assert_response :success
  end

  test "should display provider information on show page" do
    get provider_profile_url(@provider_profile)
    assert_response :success

    # Provider details
    assert_select "h1", text: /#{@provider_user.first_name} #{@provider_user.last_name}/
    assert_select "p", text: /#{@provider_profile.specialty}/
    assert_select "p", text: /#{@provider_profile.bio}/
    assert_select "p", text: /#{@provider_profile.credentials}/
  end

  test "should display provider's services on show page" do
    get provider_profile_url(@provider_profile)
    assert_response :success

    # Should show services section
    assert_select "h2", text: /Services/i
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

  test "should handle invalid provider profile id" do
    get provider_profile_url(id: 99999)
    assert_response :not_found
  end

  # New tests
  test "provider should get new" do
    sign_in @provider_user
    get new_provider_profile_url
    assert_response :success
  end

  test "patient should not get new" do
    sign_in @patient_user
    get new_provider_profile_url
    assert_redirected_to root_path
  end

  test "should not get new without authentication" do
    get new_provider_profile_url
    assert_redirected_to new_user_session_path
  end

  # Create tests
  test "provider should create provider_profile" do
    sign_in @provider_user
    # First, destroy existing profile
    @provider_user.provider_profile&.destroy

    assert_difference("ProviderProfile.count") do
      post provider_profiles_url, params: {
        provider_profile: {
          specialty: "Nutrition",
          bio: "Certified nutritionist with 5 years of experience.",
          credentials: "RD, MS in Nutrition",
          consultation_rate: 100.00
        }
      }
    end

    assert_redirected_to provider_profile_url(ProviderProfile.last)
  end

  test "patient should not create provider_profile" do
    sign_in @patient_user

    assert_no_difference("ProviderProfile.count") do
      post provider_profiles_url, params: {
        provider_profile: {
          specialty: "Nutrition",
          bio: "Test bio",
          credentials: "Test credentials",
          consultation_rate: 100.00
        }
      }
    end

    assert_redirected_to root_path
  end

  test "should not create provider_profile without authentication" do
    assert_no_difference("ProviderProfile.count") do
      post provider_profiles_url, params: {
        provider_profile: {
          specialty: "Nutrition",
          bio: "Test bio",
          credentials: "Test credentials",
          consultation_rate: 100.00
        }
      }
    end

    assert_redirected_to new_user_session_path
  end

  # Edit tests
  test "provider should get edit for own profile" do
    sign_in @provider_user
    get edit_provider_profile_url(@provider_profile)
    assert_response :success
  end

  test "patient should not get edit" do
    sign_in @patient_user
    get edit_provider_profile_url(@provider_profile)
    assert_redirected_to root_path
  end

  test "should not get edit without authentication" do
    get edit_provider_profile_url(@provider_profile)
    assert_redirected_to new_user_session_path
  end

  # Update tests
  test "provider should update own provider_profile" do
    sign_in @provider_user
    patch provider_profile_url(@provider_profile), params: {
      provider_profile: {
        specialty: "Updated Specialty",
        bio: "Updated bio"
      }
    }
    assert_redirected_to provider_profile_url(@provider_profile)

    @provider_profile.reload
    assert_equal "Updated Specialty", @provider_profile.specialty
    assert_equal "Updated bio", @provider_profile.bio
  end

  test "patient should not update provider_profile" do
    sign_in @patient_user
    patch provider_profile_url(@provider_profile), params: {
      provider_profile: {
        specialty: "Should not update"
      }
    }
    assert_redirected_to root_path

    @provider_profile.reload
    assert_not_equal "Should not update", @provider_profile.specialty
  end

  test "should not update provider_profile without authentication" do
    patch provider_profile_url(@provider_profile), params: {
      provider_profile: {
        specialty: "Should not update"
      }
    }
    assert_redirected_to new_user_session_path

    @provider_profile.reload
    assert_not_equal "Should not update", @provider_profile.specialty
  end

  # Destroy tests
  test "provider should destroy own provider_profile" do
    sign_in @provider_user
    assert_difference("ProviderProfile.count", -1) do
      delete provider_profile_url(@provider_profile)
    end

    assert_redirected_to provider_profiles_url
  end

  test "patient should not destroy provider_profile" do
    sign_in @patient_user
    assert_no_difference("ProviderProfile.count") do
      delete provider_profile_url(@provider_profile)
    end

    assert_redirected_to root_path
  end

  test "should not destroy provider_profile without authentication" do
    assert_no_difference("ProviderProfile.count") do
      delete provider_profile_url(@provider_profile)
    end

    assert_redirected_to new_user_session_path
  end
end
