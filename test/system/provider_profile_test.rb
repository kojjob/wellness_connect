require "application_system_test_case"

class ProviderProfileTest < ApplicationSystemTestCase
  setup do
    @provider_user = users(:provider_user)
    @patient_user = users(:patient_user)
    @provider_profile = provider_profiles(:provider_profile_one)
  end

  # Hero Section Tests
  test "displays provider hero section with avatar and basic info" do
    visit provider_profile_path(@provider_profile)

    assert_selector "h1", text: @provider_profile.full_name
    assert_selector "p", text: @provider_profile.credentials
    assert_selector "span", text: @provider_profile.specialty
  end

  test "displays verification badge" do
    visit provider_profile_path(@provider_profile)

    assert_selector "[title='Verified Provider']"
    assert_selector "[aria-label='Verified Provider']"
  end

  test "displays rating and review count" do
    visit provider_profile_path(@provider_profile)

    # Should display rating stars
    assert_selector "svg.text-yellow-400", count: 5 # Assuming 5-star rating
    # Should display review count
    assert_text "reviews"
  end

  test "displays years of experience badge when present" do
    @provider_profile.update(years_of_experience: 10)
    visit provider_profile_path(@provider_profile)

    assert_text "10 Years Experience"
  end

  # Navigation Tests
  test "displays sticky navigation tabs" do
    visit provider_profile_path(@provider_profile)

    assert_selector "nav[aria-label='Profile sections']"
    assert_link "About"
    assert_link "Services"
    assert_link "Availability"
    assert_link "Reviews"
    assert_link "Contact"
  end

  test "smooth scroll navigation works" do
    visit provider_profile_path(@provider_profile)

    # Click on About link
    click_link "About"
    # Should scroll to about section (we can't test actual scroll, but can verify section exists)
    assert_selector "#about"
  end

  # About Section Tests
  test "displays about section with bio" do
    visit provider_profile_path(@provider_profile)

    within "#about" do
      assert_selector "h2", text: "About #{@provider_profile.full_name}"
      assert_text @provider_profile.bio
    end
  end

  test "displays education when present" do
    @provider_profile.update(education: "PhD in Psychology, Harvard University")
    visit provider_profile_path(@provider_profile)

    within "#about" do
      assert_selector "h3", text: "Education"
      assert_text "PhD in Psychology"
    end
  end

  test "displays certifications when present" do
    @provider_profile.update(certifications: "Licensed Mental Health Counselor (LMHC)")
    visit provider_profile_path(@provider_profile)

    within "#about" do
      assert_selector "h3", text: "Certifications & Credentials"
      assert_text "Licensed Mental Health Counselor"
    end
  end

  test "displays languages when present" do
    @provider_profile.update(languages: "English, Spanish, French")
    visit provider_profile_path(@provider_profile)

    within "#about" do
      assert_selector "h3", text: "Languages Spoken"
      assert_text "English"
      assert_text "Spanish"
      assert_text "French"
    end
  end

  # Services Section Tests
  test "displays services section with active services" do
    visit provider_profile_path(@provider_profile)

    within "#services" do
      assert_selector "h2", text: "Services Offered"

      @provider_profile.services.where(is_active: true).each do |service|
        assert_text service.name
        assert_text service.description
        assert_text "$#{service.price.to_i}"
        assert_text "#{service.duration_minutes} min"
      end
    end
  end

  test "displays empty state when no services available" do
    @provider_profile.services.destroy_all
    visit provider_profile_path(@provider_profile)

    within "#services" do
      assert_text "No Services Available"
    end
  end

  test "patient can see book service buttons" do
    sign_in @patient_user
    visit provider_profile_path(@provider_profile)

    within "#services" do
      assert_button "Book This Service", minimum: 1
    end
  end

  test "unauthenticated user sees sign in to book buttons" do
    visit provider_profile_path(@provider_profile)

    within "#services" do
      assert_link "Sign In to Book", minimum: 1
    end
  end

  # Reviews Section Tests
  test "displays reviews section with rating summary" do
    visit provider_profile_path(@provider_profile)

    within "#reviews" do
      assert_selector "h2", text: "Reviews & Testimonials"
      assert_selector ".text-6xl", text: @provider_profile.display_rating.to_s
    end
  end

  test "displays testimonial carousel" do
    visit provider_profile_path(@provider_profile)

    within "#reviews" do
      # Should have at least one testimonial visible
      assert_selector "[data-carousel-target='slide']", minimum: 1
    end
  end

  test "patient can see write review CTA" do
    sign_in @patient_user
    visit provider_profile_path(@provider_profile)

    within "#reviews" do
      assert_button "Write a Review"
    end
  end

  # Booking Widget Tests
  test "displays booking widget in sidebar" do
    visit provider_profile_path(@provider_profile)

    within "#booking" do
      assert_selector "h3", text: "Book Appointment"
      assert_text "$#{@provider_profile.consultation_rate.to_i}"
      assert_text "per session"
    end
  end

  test "displays available time slots in booking widget" do
    # Create a future availability
    @provider_profile.availabilities.create!(
      start_time: 2.days.from_now.change(hour: 10, min: 0),
      end_time: 2.days.from_now.change(hour: 11, min: 0),
      is_booked: false
    )

    visit provider_profile_path(@provider_profile)

    within "#booking" do
      assert_selector "h4", text: "Next Available Slots"
      assert_selector ".bg-gray-50", minimum: 1
    end
  end

  test "displays empty state when no availability" do
    @provider_profile.availabilities.destroy_all
    visit provider_profile_path(@provider_profile)

    within "#booking" do
      assert_text "No available slots at this time"
    end
  end

  # Contact Info Tests
  test "displays contact information" do
    @provider_profile.update(
      phone: "555-123-4567",
      office_address: "123 Main St, City, State 12345"
    )
    visit provider_profile_path(@provider_profile)

    within "#contact" do
      assert_selector "h3", text: "Contact Information"
      assert_text "555-123-4567"
      assert_text @provider_profile.user.email
      assert_text "123 Main St"
    end
  end

  test "displays social media links when present" do
    @provider_profile.update(
      linkedin_url: "https://linkedin.com/in/provider",
      twitter_url: "https://twitter.com/provider",
      facebook_url: "https://facebook.com/provider",
      instagram_url: "https://instagram.com/provider"
    )
    visit provider_profile_path(@provider_profile)

    within "#contact" do
      assert_text "Connect on Social Media"
      assert_selector "a[title='LinkedIn']"
      assert_selector "a[title='Twitter']"
      assert_selector "a[title='Facebook']"
      assert_selector "a[title='Instagram']"
    end
  end

  # Quick Stats Tests
  test "displays quick stats widget" do
    visit provider_profile_path(@provider_profile)

    assert_selector "h3", text: "Quick Stats"
    assert_text "Reviews"
    assert_text "Services Offered"
    assert_text "Response Time"
  end

  # Accessibility Tests
  test "has proper ARIA labels for interactive elements" do
    visit provider_profile_path(@provider_profile)

    assert_selector "[aria-label='Verified Provider']"
    assert_selector "nav[aria-label='Profile sections']"
  end

  test "has proper heading hierarchy" do
    visit provider_profile_path(@provider_profile)

    # Should have h1 for provider name
    assert_selector "h1", count: 1
    # Should have h2 for major sections
    assert_selector "h2", minimum: 3
  end

  # Provider Edit Access Tests
  test "provider owner sees edit button" do
    sign_in @provider_user
    visit provider_profile_path(@provider_profile)

    assert_selector "a[title='Edit Profile']"
  end

  test "other users do not see edit button" do
    sign_in @patient_user
    visit provider_profile_path(@provider_profile)

    assert_no_selector "a[title='Edit Profile']"
  end

  # Responsive Design Tests
  test "displays properly on mobile viewport" do
    resize_window_to_mobile
    visit provider_profile_path(@provider_profile)

    # Hero section should be visible
    assert_selector "h1", text: @provider_profile.full_name
    # Navigation should be scrollable
    assert_selector "nav.overflow-x-auto"
  end

  private

  def resize_window_to_mobile
    page.driver.browser.manage.window.resize_to(375, 667)
  end
end
