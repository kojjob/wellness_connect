require "test_helper"

class LeadTest < ActiveSupport::TestCase
  test "valid lead with email" do
    lead = Lead.new(email: "test@example.com", source: "landing_page")
    assert lead.valid?
  end

  test "invalid without email" do
    lead = Lead.new(source: "landing_page")
    assert_not lead.valid?
    assert_includes lead.errors[:email], "can't be blank"
  end

  test "invalid with malformed email" do
    lead = Lead.new(email: "invalid-email", source: "landing_page")
    assert_not lead.valid?
    assert_includes lead.errors[:email], "is invalid"
  end

  test "email must be unique" do
    Lead.create!(email: "unique@example.com", source: "landing_page")
    duplicate = Lead.new(email: "unique@example.com", source: "landing_page")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "sets default values on creation" do
    lead = Lead.create!(email: "defaults@example.com")
    assert_equal "landing_page", lead.source
    assert_equal true, lead.subscribed
  end

  test "can set custom source" do
    lead = Lead.create!(email: "custom@example.com", source: "facebook_ad")
    assert_equal "facebook_ad", lead.source
  end

  test "can track UTM parameters" do
    lead = Lead.create!(
      email: "utm@example.com",
      utm_campaign: "summer_sale",
      utm_source: "google",
      utm_medium: "cpc"
    )
    assert_equal "summer_sale", lead.utm_campaign
    assert_equal "google", lead.utm_source
    assert_equal "cpc", lead.utm_medium
  end

  test "subscribed scope returns only subscribed leads" do
    Lead.create!(email: "subscribed@example.com", subscribed: true)
    Lead.create!(email: "unsubscribed@example.com", subscribed: false)
    
    assert_equal 1, Lead.subscribed.count
    assert_equal "subscribed@example.com", Lead.subscribed.first.email
  end

  test "recent scope orders by created_at desc" do
    old_lead = Lead.create!(email: "old@example.com")
    old_lead.update_column(:created_at, 2.days.ago)
    
    new_lead = Lead.create!(email: "new@example.com")
    
    assert_equal new_lead, Lead.recent.first
    assert_equal old_lead, Lead.recent.last
  end

  test "can unsubscribe" do
    lead = Lead.create!(email: "unsub@example.com", subscribed: true)
    lead.update!(subscribed: false)
    assert_not lead.subscribed
  end

  test "accepts valid email formats" do
    valid_emails = [
      "user@example.com",
      "user.name@example.com",
      "user+tag@example.co.uk",
      "user_name@example-domain.com"
    ]
    
    valid_emails.each do |email|
      lead = Lead.new(email: email)
      assert lead.valid?, "#{email} should be valid"
    end
  end

  test "rejects invalid email formats" do
    invalid_emails = [
      "plaintext",
      "@example.com",
      "user@",
      "user @example.com"
    ]

    invalid_emails.each do |email|
      lead = Lead.new(email: email)
      assert_not lead.valid?, "#{email} should be invalid"
    end
  end
end
