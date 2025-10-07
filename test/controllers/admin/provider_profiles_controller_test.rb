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
    assert_select "h2", "All Provider Profiles"
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
    assert_equal "You are not authorized to access this page.", flash[:alert]
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
    assert_select "h1", @provider_profile.user.full_name
    assert_select "p", text: @provider_profile.specialty
  end

  test "non-admin cannot view provider profile details" do
    sign_in @patient
    get admin_provider_profile_path(@provider_profile)
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  # ========================================
  # New/Create Action Tests
  # (Actions removed - providers create their own profiles on signup)
  # Routes excluded in routes.rb, so they don't exist and would return 404
  # Tests verify that the functionality is properly restricted
  # ========================================

  # Note: We don't test for 404 on non-existent routes as that's redundant.
  # The routes.rb file explicitly excludes :new and :create actions.

  # ========================================
  # Edit Action Tests
  # ========================================

  test "admin can access edit provider profile form" do
    sign_in @admin
    get edit_admin_provider_profile_path(@provider_profile)
    assert_response :success
    assert_select "h1", "Edit Provider Profile"
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
  # (Action removed - data integrity protection)
  # Route excluded in routes.rb, so it doesn't exist and would return 404
  # ========================================

  # Note: We don't test for 404 on non-existent routes as that's redundant.
  # The routes.rb file explicitly excludes :destroy action.
end
