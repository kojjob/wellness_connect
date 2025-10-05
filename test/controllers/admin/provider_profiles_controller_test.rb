require "test_helper"

class Admin::ProviderProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @provider_without_profile = users(:software_engineer_provider)
  end

  # ========================================
  # Index Action Tests
  # ========================================

  test "admin can access provider profiles index" do
    sign_in @admin
    get admin_provider_profiles_path
    assert_response :success
    assert_select "h2", "All Providers"
  end

  test "admin sees all provider profiles in index" do
    sign_in @admin
    get admin_provider_profiles_path
    assert_response :success
    # Should see all provider profiles
    ProviderProfile.all.each do |profile|
      assert_select "h3", text: profile.user.full_name
    end
  end

  test "admin can search provider profiles by specialty" do
    sign_in @admin
    get admin_provider_profiles_path, params: { specialty: "Business" }
    assert_response :success
    assert_select "h3", text: provider_profiles(:provider_profile_two).user.full_name
  end

  test "non-admin cannot access provider profiles index" do
    sign_in @patient
    get admin_provider_profiles_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "guest cannot access provider profiles index" do
    get admin_provider_profiles_path
    assert_redirected_to new_user_session_path
  end

  # ========================================
  # Show Action Tests
  # ========================================

  test "admin can view provider profile details" do
    sign_in @admin
    get admin_provider_profile_path(@provider_profile)
    assert_response :success
    assert_select "h2", @provider_profile.user.full_name
    assert_select "p", text: @provider_profile.specialty
  end

  test "admin can see delete button on show page" do
    sign_in @admin
    get admin_provider_profile_path(@provider_profile)
    assert_response :success
    assert_select "form[action='#{admin_provider_profile_path(@provider_profile)}'][method='post']" do
      assert_select "input[name='_method'][value='delete']", count: 1
    end
  end

  test "non-admin cannot view provider profile details" do
    sign_in @patient
    get admin_provider_profile_path(@provider_profile)
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # ========================================
  # New Action Tests
  # ========================================

  test "admin can access new provider profile form" do
    sign_in @admin
    get new_admin_provider_profile_path
    assert_response :success
    assert_select "h2", "Create Provider Profile"
    assert_select "form"
  end

  test "new provider profile form has all required fields" do
    sign_in @admin
    get new_admin_provider_profile_path
    assert_response :success
    assert_select "select[name='provider_profile[user_id]']"
    assert_select "input[name='provider_profile[specialty]']"
    assert_select "input[name='provider_profile[credentials]']"
    assert_select "input[name='provider_profile[consultation_rate]']"
    assert_select "textarea[name='provider_profile[bio]']"
  end

  test "new form shows only providers without profiles" do
    sign_in @admin
    get new_admin_provider_profile_path
    assert_response :success
    # Should include provider without profile
    assert_select "option[value='#{@provider_without_profile.id}']"
    # Should NOT include providers with existing profiles
    assert_select "option[value='#{@provider.id}']", count: 0
  end

  test "new form shows warning when no available providers" do
    sign_in @admin
    # Create profiles for all provider users who don't have one
    User.where(role: :provider).each do |user|
      next if user.provider_profile.present?
      ProviderProfile.create!(
        user: user,
        specialty: "Test Specialty",
        bio: "This is a comprehensive test bio with at least fifty characters to satisfy model validation requirements for bio length.",
        consultation_rate: 100.00
      )
    end

    get new_admin_provider_profile_path
    assert_response :success
    assert_select "p", text: /No available providers/
  end

  test "non-admin cannot access new provider profile form" do
    sign_in @patient
    get new_admin_provider_profile_path
    assert_redirected_to root_path
  end

  # ========================================
  # Create Action Tests
  # ========================================

  test "admin can create new provider profile" do
    sign_in @admin
    assert_difference("ProviderProfile.count", 1) do
      post admin_provider_profiles_path, params: {
        provider_profile: {
          user_id: @provider_without_profile.id,
          specialty: "Software Engineering Consulting",
          credentials: "BS Computer Science, 10 years experience",
          consultation_rate: 175.00,
          bio: "Experienced software engineer specializing in system architecture."
        }
      }
    end
    assert_redirected_to admin_provider_profile_path(ProviderProfile.last)
    assert_equal "Provider profile successfully created.", flash[:notice]
  end

  test "create fails with invalid data" do
    sign_in @admin
    assert_no_difference("ProviderProfile.count") do
      post admin_provider_profiles_path, params: {
        provider_profile: {
          user_id: @provider_without_profile.id,
          specialty: "", # Invalid: blank specialty
          bio: "Test bio"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create fails when user already has profile" do
    sign_in @admin
    assert_no_difference("ProviderProfile.count") do
      post admin_provider_profiles_path, params: {
        provider_profile: {
          user_id: @provider.id, # Already has provider_profile_one
          specialty: "Test Specialty",
          bio: "Test bio"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "non-admin cannot create provider profiles" do
    sign_in @patient
    assert_no_difference("ProviderProfile.count") do
      post admin_provider_profiles_path, params: {
        provider_profile: {
          user_id: @provider_without_profile.id,
          specialty: "Test",
          bio: "Test"
        }
      }
    end
    assert_redirected_to root_path
  end

  # ========================================
  # Edit Action Tests
  # ========================================

  test "admin can access edit provider profile form" do
    sign_in @admin
    get edit_admin_provider_profile_path(@provider_profile)
    assert_response :success
    assert_select "h2", "Edit Provider Profile"
    assert_select "form"
  end

  test "edit form is pre-filled with profile data" do
    sign_in @admin
    get edit_admin_provider_profile_path(@provider_profile)
    assert_response :success
    assert_select "input[name='provider_profile[specialty]'][value=?]", @provider_profile.specialty
    assert_select "textarea[name='provider_profile[bio]']", text: @provider_profile.bio
  end

  test "non-admin cannot access edit provider profile form" do
    sign_in @patient
    get edit_admin_provider_profile_path(@provider_profile)
    assert_redirected_to root_path
  end

  # ========================================
  # Update Action Tests
  # ========================================

  test "admin can update provider profile details" do
    sign_in @admin
    patch admin_provider_profile_path(@provider_profile), params: {
      provider_profile: {
        specialty: "Updated Specialty",
        consultation_rate: 250.00
      }
    }
    @provider_profile.reload
    assert_equal "Updated Specialty", @provider_profile.specialty
    assert_equal 250.00, @provider_profile.consultation_rate
    assert_redirected_to admin_provider_profile_path(@provider_profile)
    assert_equal "Provider profile successfully updated.", flash[:notice]
  end

  test "update fails with invalid data" do
    sign_in @admin
    original_specialty = @provider_profile.specialty
    patch admin_provider_profile_path(@provider_profile), params: {
      provider_profile: { specialty: "" }
    }
    assert_response :unprocessable_entity
    @provider_profile.reload
    assert_equal original_specialty, @provider_profile.specialty
  end

  test "non-admin cannot update provider profiles" do
    sign_in @patient
    original_specialty = @provider_profile.specialty
    patch admin_provider_profile_path(@provider_profile), params: {
      provider_profile: { specialty: "Hacked" }
    }
    assert_redirected_to root_path
    @provider_profile.reload
    assert_equal original_specialty, @provider_profile.specialty
  end

  # ========================================
  # Destroy Action Tests
  # ========================================

  test "admin can delete provider profile" do
    sign_in @admin
    profile_to_delete = ProviderProfile.create!(
      user: @provider_without_profile,
      specialty: "To Delete",
      bio: "This is a test provider profile bio with at least 50 characters to satisfy validation requirements.",
      consultation_rate: 100.00
    )

    assert_difference("ProviderProfile.count", -1) do
      delete admin_provider_profile_path(profile_to_delete)
    end
    assert_redirected_to admin_provider_profiles_path
    assert_equal "Provider profile successfully deleted.", flash[:notice]
  end

  test "deleting profile does not delete user" do
    sign_in @admin
    profile_to_delete = ProviderProfile.create!(
      user: @provider_without_profile,
      specialty: "To Delete",
      bio: "This is a test provider profile bio with at least 50 characters to satisfy validation requirements.",
      consultation_rate: 100.00
    )
    user_id = profile_to_delete.user_id

    assert_no_difference("User.count") do
      delete admin_provider_profile_path(profile_to_delete)
    end
    assert User.exists?(user_id), "User should still exist after profile deletion"
  end

  test "non-admin cannot delete provider profiles" do
    sign_in @patient
    assert_no_difference("ProviderProfile.count") do
      delete admin_provider_profile_path(@provider_profile)
    end
    assert_redirected_to root_path
  end
end
