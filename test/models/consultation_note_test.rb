require "test_helper"

class ConsultationNoteTest < ActiveSupport::TestCase
  def setup
    @appointment = appointments(:appointment_one)
  end

  # Validation Tests
  test "should be valid with all required attributes" do
    note = ConsultationNote.new(
      appointment: @appointment,
      content: "This is a detailed consultation note with sufficient content."
    )
    assert note.valid?, "ConsultationNote should be valid: #{note.errors.full_messages.join(', ')}"
  end

  test "should require appointment" do
    note = ConsultationNote.new(content: "Some content here for the note.")
    assert_not note.valid?
    assert_includes note.errors[:appointment], "must exist"
  end

  test "should require content" do
    note = ConsultationNote.new(appointment: @appointment)
    assert_not note.valid?
    assert_includes note.errors[:content], "can't be blank"
  end

  test "content must be at least 10 characters" do
    note = ConsultationNote.new(appointment: @appointment, content: "Short")
    assert_not note.valid?
    assert_includes note.errors[:content], "is too short (minimum is 10 characters)"
  end

  test "content cannot exceed 10000 characters" do
    note = ConsultationNote.new(appointment: @appointment, content: "a" * 10001)
    assert_not note.valid?
    assert_includes note.errors[:content], "is too long (maximum is 10000 characters)"
  end

  test "appointment can only have one consultation note" do
    ConsultationNote.create!(
      appointment: @appointment,
      content: "First consultation note with enough content."
    )

    duplicate_note = ConsultationNote.new(
      appointment: @appointment,
      content: "Second consultation note attempt."
    )
    assert_not duplicate_note.valid?
    assert_includes duplicate_note.errors[:appointment_id], "can only have one consultation note"
  end

  # Scope Tests
  test "recent scope orders by created_at desc" do
    # Create new appointments for different notes
    patient = users(:patient_user)
    provider = users(:provider_user)
    service = services(:service_one)

    old_appointment = Appointment.create!(
      patient: patient,
      provider: provider,
      service: service,
      start_time: 5.days.from_now,
      end_time: 5.days.from_now + 1.hour,
      status: :completed
    )

    new_appointment = Appointment.create!(
      patient: patient,
      provider: provider,
      service: service,
      start_time: 6.days.from_now,
      end_time: 6.days.from_now + 1.hour,
      status: :completed
    )

    old_note = ConsultationNote.create!(
      appointment: old_appointment,
      content: "Old consultation note content.",
      created_at: 1.week.ago
    )

    new_note = ConsultationNote.create!(
      appointment: new_appointment,
      content: "New consultation note content.",
      created_at: 1.day.ago
    )

    recent = ConsultationNote.recent
    assert recent.index(new_note) < recent.index(old_note)
  end

  # Instance Method Tests
  test "summary returns full content if under limit" do
    note = ConsultationNote.new(content: "Short content here.")
    assert_equal "Short content here.", note.summary
  end

  test "summary truncates long content" do
    long_content = "a" * 300
    note = ConsultationNote.new(content: long_content)
    assert_equal "a" * 200 + "...", note.summary
  end

  test "summary returns empty string for blank content" do
    note = ConsultationNote.new(content: nil)
    assert_equal "", note.summary
  end

  test "summary accepts custom length parameter" do
    content = "a" * 100
    note = ConsultationNote.new(content: content)
    assert_equal "a" * 50 + "...", note.summary(50)
  end

  # Association Tests
  test "should belong to appointment" do
    note = ConsultationNote.new(appointment: @appointment, content: "Note content here.")
    assert_respond_to note, :appointment
    assert_equal @appointment, note.appointment
  end

  # Encryption Test
  test "content should be encrypted" do
    note = ConsultationNote.create!(
      appointment: @appointment,
      content: "Sensitive medical information."
    )
    # The content attribute should have encryption configured
    assert ConsultationNote.encrypted_attributes.include?(:content)
  end
end
