require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  test "should create lead with valid email" do
    assert_difference("Lead.count", 1) do
      post leads_path, params: { lead: { email: "newlead@example.com" } }
    end
    
    assert_response :success
  end

  test "should create lead with Turbo Stream format" do
    assert_difference("Lead.count", 1) do
      post leads_path, params: { lead: { email: "turbo@example.com" } }, as: :turbo_stream
    end
    
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should create lead with JSON format" do
    assert_difference("Lead.count", 1) do
      post leads_path, params: { lead: { email: "json@example.com" } }, as: :json
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "json@example.com", json_response["email"]
    assert_equal "Lead created successfully", json_response["message"]
  end

  test "should not create lead with invalid email" do
    assert_no_difference("Lead.count") do
      post leads_path, params: { lead: { email: "invalid-email" } }
    end
    
    assert_response :unprocessable_entity
  end

  test "should not create duplicate lead" do
    Lead.create!(email: "existing@example.com")
    
    assert_no_difference("Lead.count") do
      post leads_path, params: { lead: { email: "existing@example.com" } }
    end
    
    assert_response :unprocessable_entity
  end

  test "should capture source parameter" do
    post leads_path, params: { 
      lead: { 
        email: "source@example.com",
        source: "facebook_ad"
      } 
    }
    
    lead = Lead.find_by(email: "source@example.com")
    assert_equal "facebook_ad", lead.source
  end

  test "should capture UTM parameters" do
    post leads_path, params: { 
      lead: { 
        email: "utm@example.com",
        utm_campaign: "spring_sale",
        utm_source: "google",
        utm_medium: "cpc"
      } 
    }
    
    lead = Lead.find_by(email: "utm@example.com")
    assert_equal "spring_sale", lead.utm_campaign
    assert_equal "google", lead.utm_source
    assert_equal "cpc", lead.utm_medium
  end

  test "should default source to landing_page if not provided" do
    post leads_path, params: { lead: { email: "default@example.com" } }
    
    lead = Lead.find_by(email: "default@example.com")
    assert_equal "landing_page", lead.source
  end

  test "should set subscribed to true by default" do
    post leads_path, params: { lead: { email: "subscribed@example.com" } }
    
    lead = Lead.find_by(email: "subscribed@example.com")
    assert lead.subscribed
  end
end

