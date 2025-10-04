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

    assert_selector "#availability-#{@availability.id}"
    assert_text @availability.start_time.strftime("%B %d, %Y")
    assert_text "Available"
  end

  test "patient can book an appointment through provider profile" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    within "#availability-#{@availability.id}" do
      click_button "Book Appointment"
    end

    # Should display booking form in Turbo Frame
    assert_selector "turbo-frame#appointment_booking"
    assert_text "Confirm Appointment"

    # Select service and confirm
    select @service.name, from: "Service"

    assert_difference "Appointment.count", 1 do
      click_button "Confirm Booking"
    end

    assert_text "Appointment successfully booked"
    assert_current_path dashboard_path
  end

  test "appointment creation marks availability as booked" do
    sign_in @patient
    visit provider_profile_path(@provider_profile)

    assert_not @availability.is_booked

    within "#availability-#{@availability.id}" do
      click_button "Book Appointment"
    end

    select @service.name, from: "Service"
    click_button "Confirm Booking"

    @availability.reload
    assert @availability.is_booked
  end

  test "booked availability slots are not shown as bookable" do
    @availability.update!(is_booked: true)

    sign_in @patient
    visit provider_profile_path(@provider_profile)

    # Should not show the booked availability in available slots
    refute_selector "#availability-#{@availability.id}"
  end

  test "unauthenticated user is redirected when trying to book" do
    visit provider_profile_path(@provider_profile)

    within "#availability-#{@availability.id}" do
      click_link "Book Appointment"
    end

    # Should be redirected to sign in
    assert_current_path new_user_session_path
  end

  test "provider cannot book appointments on their own profile" do
    sign_in @provider
    visit provider_profile_path(@provider_profile)

    # Should not see booking buttons on own profile
    refute_button "Book Appointment"
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

    assert @availability.is_booked

    within "#appointment-#{appointment.id}" do
      click_button "Cancel Appointment"
    end

    page.driver.browser.switch_to.alert.accept

    @availability.reload
    assert_not @availability.is_booked
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
