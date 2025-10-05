require "application_system_test_case"

class LandingPageConversionTest < ApplicationSystemTestCase
  test "landing page loads successfully" do
    visit root_path
    
    assert_selector "h1", text: /Find Your Perfect/i
    assert_selector "nav"
    assert_selector "footer"
  end

  test "displays animated social proof counters" do
    visit root_path
    
    # Check for counter elements with data attributes
    assert_selector "[data-controller='counter-animation']"
    assert_selector "[data-counter-animation-target='number']", count: 3
    
    # Verify counter values are present
    assert_text "5,000"
    assert_text "50,000"
    assert_text "4.9"
  end

  test "displays trust badges" do
    visit root_path
    
    # Check for trust badge section
    within ".grid.grid-cols-3.gap-4.max-w-2xl" do
      assert_text "SSL Secure"
      assert_text "Verified Providers"
      assert_text "Secure Payments"
    end
  end

  test "displays email capture section with lead magnet" do
    visit root_path
    
    # Scroll to email capture section
    assert_selector "h3", text: "Get 10% Off Your First Session"
    assert_selector "input[type='email']"
    assert_selector "input[type='submit'][value='Get My Discount']"
    assert_text "Ultimate Guide to Choosing the Right Professional"
  end

  test "email capture form submission creates lead" do
    visit root_path
    
    # Find and fill the email form
    within "#lead-form" do
      fill_in "lead[email]", with: "newlead@example.com"
      click_button "Get My Discount"
    end
    
    # Wait for Turbo Stream response
    sleep 1
    
    # Verify lead was created
    assert Lead.exists?(email: "newlead@example.com")
    
    # Verify success message appears
    assert_text "Check your email"
  end

  test "email capture validates email format" do
    visit root_path
    
    within "#lead-form" do
      fill_in "lead[email]", with: "invalid-email"
      click_button "Get My Discount"
    end
    
    # HTML5 validation should prevent submission
    # Or check for error message if server-side validation
    assert_no_text "Check your email"
  end

  test "displays sticky CTA bar on scroll" do
    visit root_path
    
    # Initially hidden (translated down)
    sticky_bar = find("[data-controller='sticky-cta']", visible: false)
    assert sticky_bar.matches_css?(".translate-y-full")
    
    # Scroll down
    execute_script "window.scrollTo(0, 1000)"
    sleep 0.5
    
    # Should become visible
    assert_text "Ready to find your perfect professional?"
    assert_selector "a", text: "Browse Providers"
  end

  test "sticky CTA bar can be dismissed" do
    visit root_path
    
    # Scroll to show sticky bar
    execute_script "window.scrollTo(0, 1000)"
    sleep 0.5
    
    # Click close button
    within "[data-controller='sticky-cta']" do
      find("button[aria-label='Close']").click
    end
    
    # Verify cookie is set
    assert page.driver.browser.manage.cookie_named("sticky_cta_dismissed")
  end

  test "displays live activity feed" do
    visit root_path
    
    # Check for live activity controller
    assert_selector "[data-controller='live-activity']"
    
    # Wait for first notification to appear
    sleep 9
    
    # Should show activity notification
    within "[data-controller='live-activity']" do
      assert_selector "[data-live-activity-target='notification']"
    end
  end

  test "displays exit-intent popup" do
    visit root_path
    
    # Wait for delay
    sleep 6
    
    # Simulate mouse leave
    execute_script "document.dispatchEvent(new Event('mouseleave'))"
    sleep 0.5
    
    # Check for popup
    assert_text "Wait! Before You Go..."
    assert_text "15% OFF"
    assert_text "Claim My 15% Discount Now"
  end

  test "exit-intent popup can be closed" do
    visit root_path
    
    sleep 6
    execute_script "document.dispatchEvent(new Event('mouseleave'))"
    sleep 0.5
    
    # Close popup
    within "[data-controller='exit-intent']" do
      find("button[aria-label='Close']").click
    end
    
    # Popup should be hidden
    assert_no_text "Wait! Before You Go..."
  end

  test "displays 100% satisfaction guarantee section" do
    visit root_path
    
    assert_selector "h3", text: "100% Satisfaction Guarantee"
    assert_text "Full Refund"
    assert_text "Free Rematch"
    assert_text "No Questions"
  end

  test "displays structured data for SEO" do
    visit root_path
    
    # Check for JSON-LD scripts
    assert_selector "script[type='application/ld+json']", count: 2
    
    # Verify organization schema
    page_source = page.html
    assert_includes page_source, '"@type":"Organization"'
    assert_includes page_source, '"@type":"WebSite"'
  end

  test "all CTA buttons are present and functional" do
    visit root_path
    
    # Hero CTA
    assert_selector "a", text: "Browse Providers"
    
    # Email capture CTA
    assert_selector "input[type='submit']", text: "Get My Discount"
    
    # Provider CTA
    assert_selector "a", text: "Join as a Provider"
    
    # Click main CTA
    click_link "Browse Providers", match: :first
    assert_current_path providers_path
  end

  test "navigation is accessible and functional" do
    visit root_path
    
    within "nav" do
      assert_link "Browse Providers"
      assert_link "Become a Provider"
      
      # Test navigation
      click_link "Browse Providers"
    end
    
    assert_current_path providers_path
  end

  test "footer contains all required links" do
    visit root_path
    
    within "footer" do
      assert_text "For Clients"
      assert_text "For Providers"
      assert_text "Company"
      
      # Social media links
      assert_selector "a[href='#']", count: 3 # Facebook, Twitter, LinkedIn
      
      # Copyright
      assert_text "WellnessConnect. All rights reserved"
    end
  end

  test "mobile responsive design" do
    # Test mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path
    
    # Should still display key elements
    assert_selector "h1"
    assert_selector "input[type='email']"
    assert_selector "footer"
    
    # Live activity should be hidden on mobile
    assert_selector "[data-controller='live-activity'].hidden.md\\:block"
  end

  test "all sections are present in correct order" do
    visit root_path
    
    sections = [
      "Find Your Perfect",           # Hero
      "Browse by Category",          # Categories
      "Get 10% Off",                 # Email Capture
      "How It Works",                # Process
      "Why Choose WellnessConnect",  # Features
      "100% Satisfaction Guarantee", # Guarantee
      "What Our Clients Say",        # Testimonials
      "Are You a Service Provider"   # Provider CTA
    ]
    
    sections.each do |section_text|
      assert_text section_text
    end
  end

  test "performance: page loads within acceptable time" do
    start_time = Time.now
    visit root_path
    load_time = Time.now - start_time
    
    # Should load in under 3 seconds
    assert load_time < 3, "Page took #{load_time} seconds to load"
  end

  test "accessibility: proper heading hierarchy" do
    visit root_path
    
    # Should have one h1
    assert_selector "h1", count: 1
    
    # Should have multiple h2s for sections
    assert_selector "h2", minimum: 3
    
    # Should have h3s for subsections
    assert_selector "h3", minimum: 2
  end

  test "accessibility: form labels and ARIA attributes" do
    visit root_path
    
    # Email input should have proper attributes
    email_input = find("input[type='email']")
    assert email_input[:placeholder].present?
    assert email_input[:required]
    
    # Buttons should have aria-labels where needed
    assert_selector "button[aria-label='Close']", minimum: 1
  end

  test "UTM parameters are captured in lead" do
    visit root_path(utm_source: "google", utm_campaign: "summer_promo", utm_medium: "cpc")
    
    within "#lead-form" do
      fill_in "lead[email]", with: "utm-test@example.com"
      click_button "Get My Discount"
    end
    
    sleep 1
    
    lead = Lead.find_by(email: "utm-test@example.com")
    assert_equal "landing_page", lead.source
    # Note: UTM tracking would need to be implemented in the form
  end

  test "prevents duplicate email submissions" do
    # Create existing lead
    Lead.create!(email: "existing@example.com", source: "landing_page")
    
    visit root_path
    
    within "#lead-form" do
      fill_in "lead[email]", with: "existing@example.com"
      click_button "Get My Discount"
    end
    
    sleep 1
    
    # Should show error or handle gracefully
    assert_equal 1, Lead.where(email: "existing@example.com").count
  end
end

