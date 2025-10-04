require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get become_provider" do
    get become_provider_url
    assert_response :success
    assert_select "h1", text: /Share Your Expertise/i
  end

  test "should get about" do
    get about_url
    assert_response :success
    assert_select "h1", text: /Empowering Connections/i
  end
end
