require "test_helper"

class ProviderProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider_user = users(:provider_user)
    @patient_user = users(:patient_user)
    @provider_profile = provider_profiles(:provider_profile_one)
  end

  # Index tests
  test "should get index" do
    sign_in @provider_user
    get provider_profiles_url
    assert_response :success
  end

  test "should get index without authentication" do
    get provider_profiles_url
    assert_redirected_to new_user_session_path
  end

  # Show tests
  test "should show provider_profile" do
    sign_in @provider_user
    get provider_profile_url(@provider_profile)
    assert_response :success
  end

  test "should not show provider_profile without authentication" do
    get provider_profile_url(@provider_profile)
    assert_redirected_to new_user_session_path
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
