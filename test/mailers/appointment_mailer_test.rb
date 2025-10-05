require "test_helper"

class AppointmentMailerTest < ActionMailer::TestCase
  setup do
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)
    @service = services(:service_one)

    @appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 1.week.from_now.change(hour: 10, min: 0),
      end_time: 1.week.from_now.change(hour: 11, min: 0),
      status: :scheduled
    )
  end

  test "booking_confirmation sends email to patient with appointment details" do
    mail = AppointmentMailer.booking_confirmation(@appointment)

    # Test email headers
    assert_equal "Appointment Confirmed - #{@service.name}", mail.subject
    assert_equal [ @patient.email ], mail.to
    assert_equal [ "noreply@wellnessconnect.com" ], mail.from

    # Test email body includes key information
    assert_match @patient.full_name, mail.body.encoded
    assert_match @provider.full_name, mail.body.encoded
    assert_match @service.name, mail.body.encoded
    assert_match @appointment.start_time.strftime("%B %d, %Y"), mail.body.encoded
  end

  test "provider_booking_notification sends email to provider with appointment details" do
    mail = AppointmentMailer.provider_booking_notification(@appointment)

    # Test email headers
    assert_equal "New Booking: #{@patient.full_name}", mail.subject
    assert_equal [ @provider.email ], mail.to
    assert_equal [ "noreply@wellnessconnect.com" ], mail.from

    # Test email body includes key information
    assert_match @provider.full_name, mail.body.encoded
    assert_match @patient.full_name, mail.body.encoded
    assert_match @service.name, mail.body.encoded
    assert_match @appointment.start_time.strftime("%B %d, %Y"), mail.body.encoded
  end

  test "cancellation_notification to patient includes cancellation details" do
    @appointment.update!(status: :cancelled_by_provider, cancellation_reason: "Schedule conflict")

    mail = AppointmentMailer.cancellation_notification(@appointment, @patient)

    # Test email headers
    assert_equal "Appointment Cancelled - #{@service.name}", mail.subject
    assert_equal [ @patient.email ], mail.to
    assert_equal [ "noreply@wellnessconnect.com" ], mail.from

    # Test email body includes cancellation information
    assert_match "cancelled", mail.body.encoded
    assert_match @service.name, mail.body.encoded
    assert_match "Schedule conflict", mail.body.encoded
  end

  test "cancellation_notification to provider includes cancellation details" do
    @appointment.update!(status: :cancelled_by_patient, cancellation_reason: "No longer needed")

    mail = AppointmentMailer.cancellation_notification(@appointment, @provider)

    # Test email headers
    assert_equal "Appointment Cancelled - #{@patient.full_name}", mail.subject
    assert_equal [ @provider.email ], mail.to
    assert_equal [ "noreply@wellnessconnect.com" ], mail.from

    # Test email body includes cancellation information
    assert_match "cancelled", mail.body.encoded
    assert_match @patient.full_name, mail.body.encoded
    assert_match "No longer needed", mail.body.encoded
  end
end
