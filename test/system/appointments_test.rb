require "application_system_test_case"

class AppointmentsTest < ApplicationSystemTestCase
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @service = services(:service_one)
    @availability = availabilities(:availability_one)
  end

  test "patient can view available appointments on provider profile" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    # Should see booking widget with available slots
    within "#booking" do
      assert_text "Next Available Slots"
      assert_text @availability.start_time.strftime("%b %d")
      assert_text @availability.start_time.strftime("%I:%M %p")
    end
  end

  test "patient can book an appointment through provider profile" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    # Click first available "Book" link in booking widget
    within "#booking" do
      first(:link, "Book").click
    end

    # Should navigate to appointment booking page
    assert_text "Confirm Appointment"
    assert_current_path new_appointment_path(availability_id: @availability.id)

    # Select service
    select @service.name, from: "appointment_service_id"

    # Submit form
    click_button "Confirm Booking"

    # Verify success message and redirect
    assert_text "Appointment successfully booked", wait: 5
    assert_current_path dashboard_path

    # Verify appointment appears on dashboard (use page content verification for system tests)
    assert_text @service.name
    assert_text @provider.full_name
    assert_text "Scheduled"
  end

  test "appointment creation marks availability as booked" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    # Note the time slot that is available
    slot_time = @availability.start_time.strftime("%b %d")

    # Click Book link from booking widget
    within "#booking" do
      assert_text slot_time
      first(:link, "Book").click
    end

    select @service.name, from: "appointment_service_id"
    click_button "Confirm Booking"

    # Wait for redirect to dashboard and success
    assert_current_path dashboard_path, wait: 5
    assert_text "Appointment successfully booked"

    # Verify the slot is no longer available by visiting provider profile
    visit provider_profile_path(@provider_profile)

    # The booked slot should not appear in available slots anymore
    # If this was the only slot, we should see "No available slots" message
    # Otherwise, the specific slot time should not be in the booking widget
    within "#booking" do
      # This test fixture only has one availability, so after booking it should show no slots
      assert_text "No available slots at this time"
    end
  end

  test "booked availability slots are not shown as bookable" do
    # Mark all availabilities as booked
    @provider_profile.availabilities.update_all(is_booked: true)

    sign_in @patient
    visit provider_profile_path(@provider_profile)

    # Should show "No available slots" message instead of booking list
    within "#booking" do
      assert_text "No available slots at this time"
      refute_text "Next Available Slots"
    end
  end

  test "unauthenticated user is redirected when trying to book" do
    visit provider_profile_path(@provider_profile)

    # Unauthenticated users see "Sign In to Book" button
    within "#booking" do
      click_link "Sign In to Book"
    end

    # Should be redirected to sign in
    assert_current_path new_user_session_path
  end

  test "provider cannot book appointments on their own profile" do
    sign_in @provider
    visit provider_profile_path(@provider_profile)

    # Should see booking widget but without "Book" links (providers can't book themselves)
    within "#booking" do
      assert_text "Next Available Slots"
      assert_text @availability.start_time.strftime("%b %d")
      # No "Book" links should be present for providers
      assert_no_link "Book"
    end
  end

  test "patient can view their appointments on dashboard" do
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: @availability.start_time,
      end_time: @availability.end_time,
      status: :scheduled
    )

    sign_in @patient
    visit dashboard_path

    assert_text "My Dashboard"
    assert_selector "#appointment-#{appointment.id}"
    assert_text @provider.full_name
    assert_text @service.name
    assert_text "Scheduled"
  end

  test "patient can cancel their appointment" do
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: @availability.start_time,
      end_time: @availability.end_time,
      status: :scheduled
    )
    @availability.update!(is_booked: true)

    sign_in @patient
    visit dashboard_path

    within "#appointment-#{appointment.id}" do
      click_button "Cancel Appointment"
    end

    # Confirm the Turbo confirmation dialog
    page.driver.browser.switch_to.alert.accept

    assert_text "Appointment cancelled successfully"

    appointment.reload
    assert_equal "cancelled_by_patient", appointment.status
  end

  test "cancelling appointment releases availability slot" do
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: @availability.start_time,
      end_time: @availability.end_time,
      status: :scheduled
    )
    @availability.update!(is_booked: true)

    sign_in @patient
    visit dashboard_path

    within "#appointment-#{appointment.id}" do
      click_button "Cancel Appointment"
    end

    # Accept confirmation dialog
    page.driver.browser.switch_to.alert.accept

    # Wait for page to reload and show success message
    assert_current_path dashboard_path, wait: 5

    # Verify cancellation through UI - should show cancelled status
    within "#appointment-#{appointment.id}" do
      assert_text "Cancelled"
    end

    # Check availability was released by visiting provider profile and seeing the slot available again
    visit provider_profile_path(@provider_profile)
    within "#booking" do
      assert_text "Next Available Slots"
      assert_text @availability.start_time.strftime("%b %d")
    end
  end

  test "appointment times are displayed in user timezone" do
    # Set patient's timezone
    @patient.update!(time_zone: "Eastern Time (US & Canada)")

    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: Time.zone.parse("2025-01-15 14:00:00 UTC"),
      end_time: Time.zone.parse("2025-01-15 15:00:00 UTC"),
      status: :scheduled
    )

    sign_in @patient
    visit dashboard_path

    # Should show time in Eastern timezone (UTC-5)
    # 14:00 UTC = 09:00 EST
    assert_text "09:00 AM EST"
  end
end
