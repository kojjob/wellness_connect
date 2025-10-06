require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  # Fixtures
  def setup
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @appointment = appointments(:appointment_one)
  end

  # Associations Tests
  test "should belong to patient" do
    conversation = Conversation.new(patient: @patient, provider: @provider)
    assert_equal @patient, conversation.patient
  end

  test "should belong to provider" do
    conversation = Conversation.new(patient: @patient, provider: @provider)
    assert_equal @provider, conversation.provider
  end

  test "should optionally belong to appointment" do
    conversation = Conversation.new(patient: @patient, provider: @provider, appointment: @appointment)
    assert_equal @appointment, conversation.appointment
  end

  test "should have many messages" do
    conversation = conversations(:general_conversation)
    assert_respond_to conversation, :messages
  end

  # Validation Tests
  test "should not save without patient" do
    conversation = Conversation.new(provider: @provider)
    assert_not conversation.save, "Saved conversation without patient"
    assert_includes conversation.errors[:patient], "must exist"
  end

  test "should not save without provider" do
    conversation = Conversation.new(patient: @patient)
    assert_not conversation.save, "Saved conversation without provider"
    assert_includes conversation.errors[:provider], "must exist"
  end

  test "should save valid conversation" do
    conversation = Conversation.new(patient: @patient, provider: @provider)
    assert conversation.save, "Failed to save valid conversation"
  end

  test "should not allow patient and provider to be same user" do
    conversation = Conversation.new(patient: @patient, provider: @patient)
    assert_not conversation.save, "Saved conversation with same patient and provider"
    assert_includes conversation.errors[:provider_id], "cannot be the same as patient"
  end

  test "should allow only one conversation per appointment" do
    # Create a new appointment for this test to avoid fixtures conflict
    new_appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: services(:service_one),
      start_time: 2.days.from_now,
      end_time: 2.days.from_now + 1.hour,
      status: :scheduled
    )

    # Create first conversation for appointment
    conversation1 = Conversation.create!(
      patient: @patient,
      provider: @provider,
      appointment: new_appointment
    )

    # Try to create second conversation for same appointment
    conversation2 = Conversation.new(
      patient: @patient,
      provider: @provider,
      appointment: new_appointment
    )

    assert_raises ActiveRecord::RecordNotUnique do
      conversation2.save!
    end
  end

  # Scope Tests
  test "active scope should exclude archived conversations" do
    active_conv = Conversation.create!(patient: @patient, provider: @provider)
    archived_conv = Conversation.create!(
      patient: @patient,
      provider: users(:provider_user_two),
      archived_by_patient: true
    )

    active_conversations = Conversation.active
    assert_includes active_conversations, active_conv
    assert_not_includes active_conversations, archived_conv
  end

  test "archived scope should only include archived conversations" do
    active_conv = Conversation.create!(patient: @patient, provider: @provider)
    archived_conv = Conversation.create!(
      patient: @patient,
      provider: users(:provider_user_two),
      archived_by_patient: true
    )

    archived_conversations = Conversation.archived
    assert_includes archived_conversations, archived_conv
    assert_not_includes archived_conversations, active_conv
  end

  test "with_unread scope should only include conversations with unread messages" do
    conv_with_unread = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 3
    )
    conv_without_unread = Conversation.create!(
      patient: @patient,
      provider: users(:provider_user_two),
      patient_unread_count: 0
    )

    conversations_with_unread = Conversation.with_unread
    assert_includes conversations_with_unread, conv_with_unread
    assert_not_includes conversations_with_unread, conv_without_unread
  end

  test "appointment_specific scope should only include conversations tied to appointments" do
    general_conv = Conversation.create!(patient: @patient, provider: @provider)

    # Create a new appointment for this test to avoid unique constraint issues
    new_appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: services(:service_one),
      start_time: 3.days.from_now,
      end_time: 3.days.from_now + 1.hour,
      status: :scheduled
    )

    appointment_conv = Conversation.create!(
      patient: @patient,
      provider: @provider,
      appointment: new_appointment
    )

    appointment_conversations = Conversation.appointment_specific
    assert_includes appointment_conversations, appointment_conv
    assert_not_includes appointment_conversations, general_conv
  end

  test "general scope should only include conversations not tied to appointments" do
    general_conv = Conversation.create!(patient: @patient, provider: @provider)

    # Create a new appointment for this test
    new_appointment = Appointment.create!(
      patient: @patient,
      provider: users(:provider_user_two),
      service: services(:service_one),
      start_time: 4.days.from_now,
      end_time: 4.days.from_now + 1.hour,
      status: :scheduled
    )

    appointment_conv = Conversation.create!(
      patient: @patient,
      provider: users(:provider_user_two),
      appointment: new_appointment
    )

    general_conversations = Conversation.general
    assert_includes general_conversations, general_conv
    assert_not_includes general_conversations, appointment_conv
  end

  test "ordered scope should sort by last_message_at descending" do
    old_conv = Conversation.create!(
      patient: @patient,
      provider: @provider,
      last_message_at: 2.days.ago
    )
    new_conv = Conversation.create!(
      patient: @patient,
      provider: users(:provider_user_two),
      last_message_at: 1.hour.ago
    )

    ordered_conversations = Conversation.ordered.where(id: [ old_conv.id, new_conv.id ])
    assert_equal new_conv.id, ordered_conversations.first.id, "Most recent conversation should be first"
    assert_equal old_conv.id, ordered_conversations.last.id, "Oldest conversation should be last"
  end

  # Instance Method Tests
  test "participants should return array of patient and provider" do
    conversation = Conversation.new(patient: @patient, provider: @provider)
    participants = conversation.participants

    assert_equal 2, participants.size
    assert_includes participants, @patient
    assert_includes participants, @provider
  end

  test "other_participant should return provider for patient" do
    conversation = Conversation.new(patient: @patient, provider: @provider)
    assert_equal @provider, conversation.other_participant(@patient)
  end

  test "other_participant should return patient for provider" do
    conversation = Conversation.new(patient: @patient, provider: @provider)
    assert_equal @patient, conversation.other_participant(@provider)
  end

  test "other_participant should return nil for non-participant" do
    conversation = Conversation.new(patient: @patient, provider: @provider)
    other_user = users(:patient_user_two)
    assert_nil conversation.other_participant(other_user)
  end

  test "mark_as_read_for should reset unread count for patient" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 5
    )

    conversation.mark_as_read_for(@patient)
    assert_equal 0, conversation.reload.patient_unread_count
  end

  test "mark_as_read_for should reset unread count for provider" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      provider_unread_count: 3
    )

    conversation.mark_as_read_for(@provider)
    assert_equal 0, conversation.reload.provider_unread_count
  end

  test "mark_as_read_for should not reset count for non-participant" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 5,
      provider_unread_count: 3
    )

    other_user = users(:patient_user_two)
    conversation.mark_as_read_for(other_user)

    assert_equal 5, conversation.reload.patient_unread_count
    assert_equal 3, conversation.reload.provider_unread_count
  end

  test "unread_count_for should return correct count for patient" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 5
    )

    assert_equal 5, conversation.unread_count_for(@patient)
  end

  test "unread_count_for should return correct count for provider" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      provider_unread_count: 3
    )

    assert_equal 3, conversation.unread_count_for(@provider)
  end

  test "unread_count_for should return 0 for non-participant" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 5
    )

    other_user = users(:patient_user_two)
    assert_equal 0, conversation.unread_count_for(other_user)
  end

  test "increment_unread_for should increase patient count when provider sends message" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 0
    )

    conversation.increment_unread_for(@provider)
    assert_equal 1, conversation.reload.patient_unread_count
  end

  test "increment_unread_for should increase provider count when patient sends message" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      provider_unread_count: 0
    )

    conversation.increment_unread_for(@patient)
    assert_equal 1, conversation.reload.provider_unread_count
  end

  test "has_unread_for? should return true when user has unread messages" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 3
    )

    assert conversation.has_unread_for?(@patient)
  end

  test "has_unread_for? should return false when user has no unread messages" do
    conversation = Conversation.create!(
      patient: @patient,
      provider: @provider,
      patient_unread_count: 0
    )

    assert_not conversation.has_unread_for?(@patient)
  end
end
