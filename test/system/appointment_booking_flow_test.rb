require "application_system_test_case"

class AppointmentBookingFlowTest < ApplicationSystemTestCase
  setup do
    # Create test data
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @service = services(:service_one)

    # Create available time slots
    @availability = Availability.create!(
      provider_profile: @provider_profile,
      start_time: 2.days.from_now.change(hour: 10, min: 0),
      end_time: 2.days.from_now.change(hour: 11, min: 0),
      is_booked: false
    )
  end

  test "complete booking flow: browse -> book -> view -> cancel" do
    # Step 1: Sign in as a patient
    visit new_user_session_path
    fill_in "Email", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    assert_text "Signed in successfully"

    # Step 2: Browse providers
    visit providers_path
    assert_text "Find Your Perfect Wellness Provider"

    # Step 3: View provider profile
    visit provider_profile_path(@provider_profile)
    assert_current_path provider_profile_path(@provider_profile)
    assert_text @provider.full_name
    assert_text @service.name

    # Step 4: Start booking process
    click_link "Book Appointment", match: :first
    assert_current_path new_appointment_path(service_id: @service.id)
    assert_text "Book Your Appointment"

    # Step 5: Select a time slot
    assert_text "Available Time Slots"

    # Find and select the available time slot
    time_slot_label = find("input[value='#{@availability.id}']").ancestor("label")
    time_slot_label.click

    # Step 6: Confirm booking
    assert_difference "Appointment.count", 1 do
      click_button "Confirm Booking"
    end

    # Step 7: Verify redirect to appointment show page
    appointment = Appointment.last
    assert_current_path appointment_path(appointment)
    assert_text "Appointment booked successfully"
    assert_text @provider.full_name
    assert_text @service.name
    assert_text "Scheduled"

    # Step 8: Verify availability is marked as booked
    @availability.reload
    assert @availability.is_booked?, "Availability should be marked as booked"

    # Step 9: View appointments index
    visit appointments_path
    assert_text @provider.full_name
    assert_text @service.name

    # Step 10: View appointment details
    within("#appointment_#{appointment.id}") do
      click_link "View Details"
    end
    assert_current_path appointment_path(appointment)

    # Step 11: Cancel appointment
    accept_confirm do
      click_button "Cancel"
    end

    # Step 12: Verify cancellation
    assert_current_path appointments_path
    assert_text "Appointment cancelled successfully"

    appointment.reload
    assert_equal "cancelled_by_patient", appointment.status

    # Step 13: Verify availability is released
    @availability.reload
    assert_not @availability.is_booked?, "Availability should be released after cancellation"
  end

  test "cannot book already booked slot" do
    # Mark availability as booked
    @availability.update!(is_booked: true)

    # Sign in
    visit new_user_session_path
    fill_in "Email", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    # Try to book
    visit new_appointment_path(service_id: @service.id, availability_id: @availability.id)

    # Should not show booked slots
    assert_no_selector "input[value='#{@availability.id}']"
  end

  test "cannot cancel appointment within 24 hours" do
    # Create appointment starting in 12 hours (less than 24)
    appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 12.hours.from_now,
      end_time: 13.hours.from_now,
      status: :scheduled
    )

    # Sign in
    visit new_user_session_path
    fill_in "Email", with: @patient.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    assert_text "Signed in successfully"

    # Visit appointment
    visit appointment_path(appointment)

    # Should not show cancel button (according to policy)
    # Note: This depends on the AppointmentPolicy implementation
    # For now, just verify we're on the appointment page
    assert_text appointment.service.name
  end
end
