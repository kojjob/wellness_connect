require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  def setup
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @service = services(:service_one)
    @appointment = appointments(:appointment_one)
  end

  # Validation Tests
  test "should be valid with all required attributes" do
    appointment = Appointment.new(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 2.days.from_now,
      end_time: 2.days.from_now + 1.hour,
      status: :scheduled
    )
    assert appointment.valid?, "Appointment should be valid: #{appointment.errors.full_messages.join(', ')}"
  end

  test "should require start_time" do
    @appointment.start_time = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:start_time], "can't be blank"
  end

  test "should require end_time" do
    @appointment.end_time = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:end_time], "can't be blank"
  end

  test "should require patient" do
    @appointment.patient = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:patient], "must exist"
  end

  test "should require provider" do
    @appointment.provider = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:provider], "must exist"
  end

  test "should require service" do
    @appointment.service = nil
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:service], "must exist"
  end

  test "end_time must be after start_time" do
    @appointment.start_time = 2.days.from_now
    @appointment.end_time = 2.days.from_now - 1.hour
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:end_time], "must be after start time"
  end

  test "end_time cannot equal start_time" do
    time = 2.days.from_now
    @appointment.start_time = time
    @appointment.end_time = time
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:end_time], "must be after start time"
  end

  test "patient and provider cannot be the same user" do
    @appointment.provider = @patient
    assert_not @appointment.valid?
    assert_includes @appointment.errors[:patient_id], "cannot be the same as provider"
  end

  test "start_time must be in the future on create" do
    appointment = Appointment.new(
      patient: @patient,
      provider: @provider,
      service: @service,
      start_time: 1.hour.ago,
      end_time: Time.current,
      status: :scheduled
    )
    assert_not appointment.valid?
    assert_includes appointment.errors[:start_time], "must be in the future"
  end

  # Status Enum Tests
  test "should have correct status values" do
    assert_equal 0, Appointment.statuses[:scheduled]
    assert_equal 1, Appointment.statuses[:completed]
    assert_equal 2, Appointment.statuses[:cancelled_by_patient]
    assert_equal 3, Appointment.statuses[:cancelled_by_provider]
    assert_equal 4, Appointment.statuses[:no_show]
    assert_equal 5, Appointment.statuses[:payment_pending]
  end

  test "default status should be payment_pending" do
    appointment = Appointment.new
    assert_equal "payment_pending", appointment.status
  end

  # Scope Tests
  test "upcoming scope returns future active appointments" do
    # Create a future scheduled appointment
    future_appointment = Appointment.create!(
      patient: users(:patient_user_two),
      provider: @provider,
      service: @service,
      start_time: 5.days.from_now,
      end_time: 5.days.from_now + 1.hour,
      status: :scheduled
    )

    upcoming = Appointment.upcoming
    assert_includes upcoming, future_appointment
  end

  test "active scope returns scheduled and payment_pending appointments" do
    @appointment.update_column(:status, :scheduled)
    active = Appointment.active
    assert_includes active, @appointment
  end

  # Instance Method Tests
  test "duration_minutes returns correct duration" do
    @appointment.start_time = Time.current
    @appointment.end_time = Time.current + 90.minutes
    assert_equal 90, @appointment.duration_minutes
  end

  test "duration_minutes returns 0 when times are nil" do
    @appointment.start_time = nil
    @appointment.end_time = nil
    assert_equal 0, @appointment.duration_minutes
  end

  test "cancellable? returns true for scheduled appointments" do
    @appointment.status = :scheduled
    assert @appointment.cancellable?
  end

  test "cancellable? returns true for payment_pending appointments" do
    @appointment.status = :payment_pending
    assert @appointment.cancellable?
  end

  test "cancellable? returns false for completed appointments" do
    @appointment.status = :completed
    assert_not @appointment.cancellable?
  end

  test "cancelled? returns true for cancelled_by_patient" do
    @appointment.status = :cancelled_by_patient
    assert @appointment.cancelled?
  end

  test "cancelled? returns true for cancelled_by_provider" do
    @appointment.status = :cancelled_by_provider
    assert @appointment.cancelled?
  end

  test "cancelled? returns false for scheduled" do
    @appointment.status = :scheduled
    assert_not @appointment.cancelled?
  end

  # Association Tests
  test "should belong to patient" do
    assert_respond_to @appointment, :patient
    assert_equal @patient, @appointment.patient
  end

  test "should belong to provider" do
    assert_respond_to @appointment, :provider
  end

  test "should belong to service" do
    assert_respond_to @appointment, :service
  end

  test "should have one payment" do
    assert_respond_to @appointment, :payment
  end

  test "should have one consultation_note" do
    assert_respond_to @appointment, :consultation_note
  end

  test "should have one conversation" do
    assert_respond_to @appointment, :conversation
  end

  # Dependent Destroy Tests
  test "destroying appointment destroys associated payment" do
    payment = Payment.create!(
      payer: @patient,
      appointment: @appointment,
      amount: 100,
      currency: "USD",
      status: :pending
    )

    assert_difference "Payment.count", -1 do
      @appointment.destroy
    end
  end
end
