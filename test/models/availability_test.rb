require "test_helper"

class AvailabilityTest < ActiveSupport::TestCase
  def setup
    @provider_profile = provider_profiles(:provider_profile_one)
    @availability = availabilities(:availability_one)
  end

  # Validation Tests
  test "should be valid with all required attributes" do
    availability = Availability.new(
      provider_profile: @provider_profile,
      start_time: 3.days.from_now.beginning_of_day + 9.hours,
      end_time: 3.days.from_now.beginning_of_day + 10.hours,
      is_booked: false
    )
    assert availability.valid?, "Availability should be valid: #{availability.errors.full_messages.join(', ')}"
  end

  test "should require start_time" do
    @availability.start_time = nil
    assert_not @availability.valid?
    assert_includes @availability.errors[:start_time], "can't be blank"
  end

  test "should require end_time" do
    @availability.end_time = nil
    assert_not @availability.valid?
    assert_includes @availability.errors[:end_time], "can't be blank"
  end

  test "should require provider_profile" do
    @availability.provider_profile = nil
    assert_not @availability.valid?
    assert_includes @availability.errors[:provider_profile], "must exist"
  end

  test "end_time must be after start_time" do
    @availability.start_time = 3.days.from_now
    @availability.end_time = 3.days.from_now - 1.hour
    assert_not @availability.valid?
    assert_includes @availability.errors[:end_time], "must be after start time"
  end

  test "end_time cannot equal start_time" do
    time = 3.days.from_now
    @availability.start_time = time
    @availability.end_time = time
    assert_not @availability.valid?
    assert_includes @availability.errors[:end_time], "must be after start time"
  end

  # Default Value Tests
  test "is_booked defaults to false" do
    availability = Availability.new(
      provider_profile: @provider_profile,
      start_time: 4.days.from_now,
      end_time: 4.days.from_now + 1.hour
    )
    assert_equal false, availability.is_booked
  end

  # Association Tests
  test "should belong to provider_profile" do
    assert_respond_to @availability, :provider_profile
    assert_equal @provider_profile, @availability.provider_profile
  end

  # State Tests
  test "can be marked as booked" do
    @availability.is_booked = true
    assert @availability.is_booked
  end

  test "can be marked as available after being booked" do
    @availability.is_booked = true
    @availability.save!
    @availability.is_booked = false
    @availability.save!
    assert_not @availability.is_booked
  end

  # Query Tests
  test "can find available slots" do
    @availability.update!(is_booked: false)
    available = Availability.where(is_booked: false)
    assert_includes available, @availability
  end

  test "can find booked slots" do
    @availability.update!(is_booked: true)
    booked = Availability.where(is_booked: true)
    assert_includes booked, @availability
  end
end
