require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @provider_user = users(:provider_user)
    @patient_user = users(:patient_user)
  end

  # Authorization tests
  test "should require admin authentication for index" do
    get admin_users_path
    assert_redirected_to new_user_session_path
  end

  test "should allow admin to access index" do
    sign_in @admin_user
    get admin_users_path
    assert_response :success
  end

  test "should not allow provider to access index" do
    sign_in @provider_user
    get admin_users_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "should not allow patient to access index" do
    sign_in @patient_user
    get admin_users_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  # Index action tests
  test "should list all users" do
    sign_in @admin_user
    get admin_users_path
    assert_response :success
    assert_match /#{@admin_user.email}/i, response.body
    assert_match /#{@provider_user.email}/i, response.body
    assert_match /#{@patient_user.email}/i, response.body
  end

  test "should filter users by role" do
    sign_in @admin_user
    get admin_users_path, params: { role: "provider" }
    assert_response :success
    assert_match /#{@provider_user.email}/i, response.body
  end

  test "should search users by email" do
    sign_in @admin_user
    get admin_users_path, params: { search: @patient_user.email }
    assert_response :success
    assert_match /#{@patient_user.email}/i, response.body
  end

  test "should search users by first name" do
    sign_in @admin_user
    get admin_users_path, params: { search: @patient_user.first_name }
    assert_response :success
    assert_match /#{@patient_user.email}/i, response.body
  end

  test "should search users by last name" do
    sign_in @admin_user
    get admin_users_path, params: { search: @patient_user.last_name }
    assert_response :success
    assert_match /#{@patient_user.email}/i, response.body
  end

  # Show action tests
  test "should show user details as admin" do
    sign_in @admin_user
    get admin_user_path(@patient_user)
    assert_response :success
    assert_match /#{@patient_user.full_name}/i, response.body
    assert_match /#{@patient_user.email}/i, response.body
  end

  test "should not allow provider to view user details" do
    sign_in @provider_user
    get admin_user_path(@patient_user)
    assert_redirected_to root_path
  end

  # Edit action tests
  test "should get edit form as admin" do
    sign_in @admin_user
    get edit_admin_user_path(@patient_user)
    assert_response :success
    assert_select "form[action=?]", admin_user_path(@patient_user)
  end

  test "should not allow provider to edit user" do
    sign_in @provider_user
    get edit_admin_user_path(@patient_user)
    assert_redirected_to root_path
  end

  # Update action tests
  test "should update user as admin" do
    sign_in @admin_user
    patch admin_user_path(@patient_user), params: {
      user: {
        first_name: "Updated",
        last_name: "Name",
        email: @patient_user.email,
        role: @patient_user.role
      }
    }

    assert_redirected_to admin_user_path(@patient_user)
    assert_equal "User successfully updated.", flash[:notice]
    @patient_user.reload
    assert_equal "Updated", @patient_user.first_name
    assert_equal "Name", @patient_user.last_name
  end

  test "should not allow provider to update user" do
    sign_in @provider_user
    patch admin_user_path(@patient_user), params: {
      user: { first_name: "Hacked" }
    }

    assert_redirected_to root_path
    @patient_user.reload
    assert_not_equal "Hacked", @patient_user.first_name
  end

  test "should not update user with invalid data" do
    sign_in @admin_user
    patch admin_user_path(@patient_user), params: {
      user: { email: "" }
    }

    assert_response :unprocessable_entity
  end

  test "should update user role as admin" do
    sign_in @admin_user
    original_role = @patient_user.role

    patch admin_user_path(@patient_user), params: {
      user: {
        first_name: @patient_user.first_name,
        last_name: @patient_user.last_name,
        email: @patient_user.email,
        role: "provider"
      }
    }

    assert_redirected_to admin_user_path(@patient_user)
    @patient_user.reload
    assert_equal "provider", @patient_user.role
  end
end
