require "test_helper"

class AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @patient = users(:patient_user)
    @availability = availabilities(:availability_one)
    @another_provider = users(:provider_user_two)
    @another_provider_profile = provider_profiles(:provider_profile_two)
  end

  # Index tests
  test "should get index when authenticated" do
    sign_in @patient
    get provider_profile_availabilities_url(@provider_profile)
    assert_response :success
  end

  test "should not get index when not authenticated" do
    get provider_profile_availabilities_url(@provider_profile)
    assert_redirected_to new_user_session_url
  end

  # Show tests
  test "should show availability when authenticated" do
    sign_in @patient
    get provider_profile_availability_url(@provider_profile, @availability)
    assert_response :success
  end

  test "should not show availability when not authenticated" do
    get provider_profile_availability_url(@provider_profile, @availability)
    assert_redirected_to new_user_session_url
  end

  # New tests
  test "should get new when provider owns profile" do
    sign_in @provider
    get new_provider_profile_availability_url(@provider_profile)
    assert_response :success
  end

  test "should not get new when user is not provider" do
    sign_in @patient
    get new_provider_profile_availability_url(@provider_profile)
    assert_redirected_to root_url
  end

  test "should not get new when provider does not own profile" do
    sign_in @another_provider
    get new_provider_profile_availability_url(@provider_profile)
    assert_redirected_to root_url
  end

  # Create tests
  test "should create availability when provider owns profile" do
    sign_in @provider
    assert_difference("Availability.count", 1) do
      post provider_profile_availabilities_url(@provider_profile), params: {
        availability: {
          start_time: 2.days.from_now.change(hour: 9, min: 0),
          end_time: 2.days.from_now.change(hour: 10, min: 0),
          is_booked: false
        }
      }
    end
    assert_redirected_to provider_profile_availabilities_url(@provider_profile)
  end

  test "should not create availability when user is not provider" do
    sign_in @patient
    assert_no_difference("Availability.count") do
      post provider_profile_availabilities_url(@provider_profile), params: {
        availability: {
          start_time: 2.days.from_now.change(hour: 9, min: 0),
          end_time: 2.days.from_now.change(hour: 10, min: 0)
        }
      }
    end
    assert_redirected_to root_url
  end

  test "should not create availability when provider does not own profile" do
    sign_in @another_provider
    assert_no_difference("Availability.count") do
      post provider_profile_availabilities_url(@provider_profile), params: {
        availability: {
          start_time: 2.days.from_now.change(hour: 9, min: 0),
          end_time: 2.days.from_now.change(hour: 10, min: 0)
        }
      }
    end
    assert_redirected_to root_url
  end

  test "should not create availability with invalid attributes" do
    sign_in @provider
    assert_no_difference("Availability.count") do
      post provider_profile_availabilities_url(@provider_profile), params: {
        availability: {
          start_time: nil,
          end_time: nil
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create availability when end time is before start time" do
    sign_in @provider
    assert_no_difference("Availability.count") do
      post provider_profile_availabilities_url(@provider_profile), params: {
        availability: {
          start_time: 2.days.from_now.change(hour: 10, min: 0),
          end_time: 2.days.from_now.change(hour: 9, min: 0)
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit tests
  test "should get edit when provider owns profile" do
    sign_in @provider
    get edit_provider_profile_availability_url(@provider_profile, @availability)
    assert_response :success
  end

  test "should not get edit when user is not provider" do
    sign_in @patient
    get edit_provider_profile_availability_url(@provider_profile, @availability)
    assert_redirected_to root_url
  end

  test "should not get edit when provider does not own profile" do
    sign_in @another_provider
    get edit_provider_profile_availability_url(@provider_profile, @availability)
    assert_redirected_to root_url
  end

  # Update tests
  test "should update availability when provider owns profile" do
    sign_in @provider
    new_start_time = 3.days.from_now.change(hour: 14, min: 0)
    new_end_time = 3.days.from_now.change(hour: 15, min: 0)
    patch provider_profile_availability_url(@provider_profile, @availability), params: {
      availability: {
        start_time: new_start_time,
        end_time: new_end_time
      }
    }
    assert_redirected_to provider_profile_availabilities_url(@provider_profile)
    @availability.reload
    assert_equal new_start_time.to_i, @availability.start_time.to_i
    assert_equal new_end_time.to_i, @availability.end_time.to_i
  end

  test "should not update availability when user is not provider" do
    sign_in @patient
    original_start_time = @availability.start_time
    patch provider_profile_availability_url(@provider_profile, @availability), params: {
      availability: {
        start_time: 3.days.from_now.change(hour: 14, min: 0)
      }
    }
    assert_redirected_to root_url
    @availability.reload
    assert_equal original_start_time.to_i, @availability.start_time.to_i
  end

  test "should not update availability when provider does not own profile" do
    sign_in @another_provider
    original_start_time = @availability.start_time
    patch provider_profile_availability_url(@provider_profile, @availability), params: {
      availability: {
        start_time: 3.days.from_now.change(hour: 14, min: 0)
      }
    }
    assert_redirected_to root_url
    @availability.reload
    assert_equal original_start_time.to_i, @availability.start_time.to_i
  end

  test "should not update availability with invalid attributes" do
    sign_in @provider
    patch provider_profile_availability_url(@provider_profile, @availability), params: {
      availability: {
        start_time: nil
      }
    }
    assert_response :unprocessable_entity
  end

  # Destroy tests
  test "should destroy availability when provider owns profile" do
    sign_in @provider
    assert_difference("Availability.count", -1) do
      delete provider_profile_availability_url(@provider_profile, @availability)
    end
    assert_redirected_to provider_profile_availabilities_url(@provider_profile)
  end

  test "should not destroy availability when user is not provider" do
    sign_in @patient
    assert_no_difference("Availability.count") do
      delete provider_profile_availability_url(@provider_profile, @availability)
    end
    assert_redirected_to root_url
  end

  test "should not destroy availability when provider does not own profile" do
    sign_in @another_provider
    assert_no_difference("Availability.count") do
      delete provider_profile_availability_url(@provider_profile, @availability)
    end
    assert_redirected_to root_url
  end
end
