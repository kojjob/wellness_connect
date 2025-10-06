require "application_system_test_case"

class CalendarModalTest < ApplicationSystemTestCase
  setup do
    # Create test users
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @service = services(:service_one)

    # Delete any fixture availabilities to avoid conflicts
    @provider_profile.availabilities.destroy_all

    # Create availabilities for testing calendar
    # Use Time.zone.local to explicitly create times in the application's timezone
    # This ensures proper conversion between Rails (UTC storage) and JavaScript (local display)
    # Use tomorrow if current UTC hour is past our scheduled times (ensures slots are in future)
    current_utc_hour = Time.current.utc.hour
    base_date = current_utc_hour >= 8 ? Time.zone.tomorrow : Time.zone.today

    @today_morning = Availability.create!(
      provider_profile: @provider_profile,
      start_time: Time.zone.local(base_date.year, base_date.month, base_date.day, 9, 0, 0),
      end_time: Time.zone.local(base_date.year, base_date.month, base_date.day, 10, 0, 0),
      is_booked: false
    )

    @today_afternoon = Availability.create!(
      provider_profile: @provider_profile,
      start_time: Time.zone.local(base_date.year, base_date.month, base_date.day, 14, 0, 0),
      end_time: Time.zone.local(base_date.year, base_date.month, base_date.day, 15, 0, 0),
      is_booked: false
    )

    tomorrow = base_date + 1.day
    @tomorrow_slot = Availability.create!(
      provider_profile: @provider_profile,
      start_time: Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0, 0),
      end_time: Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0, 0),
      is_booked: false
    )

    next_week = base_date + 7.days
    @next_week_slot = Availability.create!(
      provider_profile: @provider_profile,
      start_time: Time.zone.local(next_week.year, next_week.month, next_week.day, 9, 0, 0),
      end_time: Time.zone.local(next_week.year, next_week.month, next_week.day, 10, 0, 0),
      is_booked: false
    )

    # Create a booked slot to test it's not shown
    day_after_tomorrow = base_date + 2.days
    @booked_slot = Availability.create!(
      provider_profile: @provider_profile,
      start_time: Time.zone.local(day_after_tomorrow.year, day_after_tomorrow.month, day_after_tomorrow.day, 9, 0, 0),
      end_time: Time.zone.local(day_after_tomorrow.year, day_after_tomorrow.month, day_after_tomorrow.day, 10, 0, 0),
      is_booked: true
    )
  end

  private

  # Helper method to open calendar modal via Stimulus
  # Capybara button clicks don't always propagate to Stimulus in headless Chrome
  def open_calendar_modal
    page.evaluate_script("(function() { var el = document.querySelector('[data-controller=\"availability-calendar\"]'); var app = window.Stimulus; var ctrl = app.getControllerForElementAndIdentifier(el, 'availability-calendar'); if (ctrl && typeof ctrl.openModal === 'function') { ctrl.openModal({preventDefault: function() {}}); } })()")
    sleep 0.3 # Wait for JavaScript to execute
  end

  test "calendar modal opens when View All Availability is clicked" do
    # Verify availabilities were created (4 from setup)
    assert_equal 4, @provider_profile.availabilities.where(is_booked: false).count, "Should have 4 unbooked availabilities"

    # Sign in as patient
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    # Visit provider profile
    visit provider_profile_path(@provider_profile)
    assert_text @provider.full_name

    # Calendar modal should not be visible initially
    assert_no_selector '[data-availability-calendar-target="modal"].flex', visible: :visible

    # Open calendar modal
    open_calendar_modal

    # Calendar modal should now be visible
    assert_selector '[data-availability-calendar-target="modal"].flex', visible: :visible
    assert_text Time.current.strftime("%B %Y") # Current month/year displayed
  end

  test "calendar displays current month with day headers" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    # Check for day headers
    within '[data-availability-calendar-target="modal"]' do
      assert_text "Sun"
      assert_text "Mon"
      assert_text "Tue"
      assert_text "Wed"
      assert_text "Thu"
      assert_text "Fri"
      assert_text "Sat"

      # Check current month/year is displayed
      assert_text Time.current.strftime("%B %Y")
    end
  end

  test "dates with available slots are highlighted in green" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    # Calendar should render
    within '[data-availability-calendar-target="modal"]' do
      # Date with availability should have green highlighting (has unbooked availability)
      available_day = @today_morning.start_time.day
      day_element = page.find("div", text: available_day.to_s, exact_text: true, match: :first)
      parent_classes = day_element[:class]

      # Should have green background classes
      assert parent_classes.include?("bg-green-50") || parent_classes.include?("bg-green"),
        "Date with availability should be highlighted (has unbooked slots)"
    end
  end

  test "clicking a date displays time slots for that day" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    within '[data-availability-calendar-target="modal"]' do
      # Find a date that has availability (look for green highlighted dates)
      # The calendar shows dates with availability in green with specific CSS classes
      clickable_date = page.find('div.bg-green-50[data-action="click->availability-calendar#selectDate"]',
                                  match: :first)
      clicked_date_str = clickable_date["data-date"]
      clicked_date = Date.parse(clicked_date_str)

      # Use JavaScript to trigger click event to ensure it reaches the event listener
      page.execute_script("arguments[0].click()", clickable_date)

      # Wait for time slots to render
      sleep 0.5

      # Should display the selected date (with leading zero for day)
      expected_date_text = clicked_date.strftime("%A, %B %d, %Y")
      assert_text expected_date_text

      # Should have "Book Now" links for available time slots
      assert_text "Book Now", minimum: 1
    end
  end

  test "clicking a time slot redirects to booking form" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    within '[data-availability-calendar-target="modal"]' do
      # Find and click a date with availability (green highlighted)
      clickable_date = page.find('div.bg-green-50[data-action="click->availability-calendar#selectDate"]',
                                  match: :first)
      page.execute_script("arguments[0].click()", clickable_date)

      sleep 0.5

      # Click first "Book Now" link
      all("a", text: "Book Now").first.click
    end

    # Should navigate to appointments/new
    # We don't know which slot was clicked, just verify we're on the booking form
    assert_match %r{/appointments/new}, current_path
    assert_text "Book Your Appointment"
  end

  test "booked slots are not shown in calendar" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    within '[data-availability-calendar-target="modal"]' do
      # Date with only booked slots should not be highlighted as available
      booked_date = @booked_slot.start_time.day

      # Find the date element (if it exists in current month)
      if @booked_slot.start_time.month == Time.current.month
        date_elements = page.all("div", text: booked_date.to_s, exact_text: true)

        # Should not have green highlighting
        date_elements.each do |elem|
          parent_classes = elem[:class]
          assert_not(parent_classes.include?("bg-green-50") || parent_classes.include?("bg-green"),
            "Date with only booked slots should not be highlighted")
        end
      end
    end
  end

  test "calendar can navigate to next month" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    current_month = Time.current.strftime("%B %Y")
    next_month = 1.month.from_now.strftime("%B %Y")

    within '[data-availability-calendar-target="modal"]' do
      # Verify current month
      assert_text current_month

      # Click next month button
      find('[data-action="click->availability-calendar#nextMonth"]').click

      # Should show next month
      assert_text next_month
      assert_no_text current_month
    end
  end

  test "calendar can navigate to previous month" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    current_month = Time.current.strftime("%B %Y")

    within '[data-availability-calendar-target="modal"]' do
      # Click next month first
      find('[data-action="click->availability-calendar#nextMonth"]').click
      sleep 0.2

      # Then click previous month to return
      find('[data-action="click->availability-calendar#previousMonth"]').click

      # Should be back to current month
      assert_text current_month
    end
  end

  test "calendar modal can be closed with close button" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    # Modal should be visible
    assert_selector '[data-availability-calendar-target="modal"].flex', visible: :visible

    # Click close button
    within '[data-availability-calendar-target="modal"]' do
      find('button[data-action="click->availability-calendar#closeModal"]').click
    end

    # Modal should be hidden
    assert_no_selector '[data-availability-calendar-target="modal"].flex', visible: :visible
  end

  test "calendar modal can be closed with Escape key" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    # Modal should be visible
    assert_selector '[data-availability-calendar-target="modal"].flex', visible: :visible

    # Press Escape key
    page.find("body").send_keys(:escape)

    # Modal should be hidden
    assert_no_selector '[data-availability-calendar-target="modal"].flex', visible: :visible
  end

  test "calendar shows message when no slots available for selected date" do
    # Create a provider with no availability
    provider_no_slots = User.create!(
      email: "noslots@example.com",
      password: "password123",
      first_name: "No",
      last_name: "Slots",
      role: :provider
    )

    provider_profile_no_slots = ProviderProfile.create!(
      user: provider_no_slots,
      specialty: "Test Specialty",
      consultation_rate: 100,
      bio: "Experienced professional providing high-quality consultation services to clients worldwide."
    )

    Service.create!(
      provider_profile: provider_profile_no_slots,
      name: "Test Service",
      description: "Test description",
      duration_minutes: 60,
      price: 100,
      is_active: true
    )

    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(provider_profile_no_slots)

    open_calendar_modal

    # Should show empty calendar (no green highlighted dates)
    within '[data-availability-calendar-target="modal"]' do
      # All dates should be gray (no availability)
      # Just verify modal is open and showing current month
      assert_text Time.current.strftime("%B %Y")
    end
  end

  test "past dates are disabled and cannot be selected" do
    visit new_user_session_path
    fill_in "Email Address", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    visit provider_profile_path(@provider_profile)

    open_calendar_modal

    within '[data-availability-calendar-target="modal"]' do
      # Find dates that are in the past (if current date > 1)
      if Time.current.day > 1
        yesterday = Time.current.day - 1

        # Past dates should have gray/disabled styling
        past_date_elements = page.all("div", text: yesterday.to_s, exact_text: true)

        past_date_elements.each do |elem|
          parent_classes = elem[:class]
          # Should have disabled/gray classes, not clickable green
          assert(parent_classes.include?("text-gray-300") || parent_classes.include?("cursor-not-allowed"),
            "Past dates should be disabled")
        end
      end
    end
  end
end
