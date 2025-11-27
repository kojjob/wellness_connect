require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def setup
    @patient = users(:patient_user)
    @provider = users(:provider_user)
    @provider_profile = provider_profiles(:provider_profile_one)

    # Create a completed appointment so the patient can review
    @completed_appointment = Appointment.create!(
      patient: @patient,
      provider: @provider,
      service: services(:service_one),
      start_time: 2.days.ago,
      end_time: 2.days.ago + 1.hour,
      status: :completed
    )
  end

  # Validation Tests
  test "should be valid with all required attributes" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 5,
      comment: "Great session!"
    )
    assert review.valid?, "Review should be valid: #{review.errors.full_messages.join(', ')}"
  end

  test "should require rating" do
    review = Review.new(reviewer: @patient, provider_profile: @provider_profile)
    assert_not review.valid?
    assert_includes review.errors[:rating], "can't be blank"
  end

  test "rating must be at least 1" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 0
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "must be greater than or equal to 1"
  end

  test "rating must be at most 5" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 6
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "must be less than or equal to 5"
  end

  test "rating must be an integer" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 4.5
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "must be an integer"
  end

  test "comment can be blank" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 5
    )
    assert review.valid?
  end

  test "comment cannot exceed 1000 characters" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 5,
      comment: "a" * 1001
    )
    assert_not review.valid?
    assert_includes review.errors[:comment], "is too long (maximum is 1000 characters)"
  end

  test "reviewer can only review a provider once" do
    Review.create!(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 5
    )

    duplicate_review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 4
    )
    assert_not duplicate_review.valid?
    assert_includes duplicate_review.errors[:reviewer_id], "can only review a provider once"
  end

  test "reviewer cannot review their own profile" do
    review = Review.new(
      reviewer: @provider,
      provider_profile: @provider_profile,
      rating: 5
    )
    assert_not review.valid?
    assert_includes review.errors[:reviewer], "cannot review their own profile"
  end

  test "reviewer must have completed appointment with provider" do
    other_patient = users(:patient_user_two)
    review = Review.new(
      reviewer: other_patient,
      provider_profile: @provider_profile,
      rating: 5
    )
    assert_not review.valid?
    assert_includes review.errors[:base], "You must have a completed appointment to leave a review"
  end

  # Scope Tests
  test "recent scope orders by created_at desc" do
    old_review = Review.create!(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 4,
      created_at: 1.week.ago
    )

    # Create completed appointment for patient_user_two
    other_patient = users(:patient_user_two)
    Appointment.create!(
      patient: other_patient,
      provider: @provider,
      service: services(:service_one),
      start_time: 3.days.ago,
      end_time: 3.days.ago + 1.hour,
      status: :completed
    )

    new_review = Review.create!(
      reviewer: other_patient,
      provider_profile: @provider_profile,
      rating: 5,
      created_at: 1.day.ago
    )

    recent = Review.recent
    assert recent.index(new_review) < recent.index(old_review)
  end

  test "highest_rated scope orders by rating desc" do
    low_review = Review.create!(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 2
    )

    # Create completed appointment for patient_user_two
    other_patient = users(:patient_user_two)
    Appointment.create!(
      patient: other_patient,
      provider: @provider,
      service: services(:service_one),
      start_time: 3.days.ago,
      end_time: 3.days.ago + 1.hour,
      status: :completed
    )

    high_review = Review.create!(
      reviewer: other_patient,
      provider_profile: @provider_profile,
      rating: 5
    )

    highest = Review.highest_rated
    assert highest.index(high_review) < highest.index(low_review)
  end

  test "with_comments scope returns only reviews with comments" do
    review_with_comment = Review.create!(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 5,
      comment: "Great!"
    )

    reviews_with_comments = Review.with_comments
    assert_includes reviews_with_comments, review_with_comment
  end

  # Instance Method Tests
  test "display_rating_stars returns correct stars" do
    review = Review.new(rating: 3)
    assert_equal "★★★☆☆", review.display_rating_stars
  end

  test "display_rating_stars for 5 stars" do
    review = Review.new(rating: 5)
    assert_equal "★★★★★", review.display_rating_stars
  end

  test "display_rating_stars for 1 star" do
    review = Review.new(rating: 1)
    assert_equal "★☆☆☆☆", review.display_rating_stars
  end

  test "short_comment returns full comment if under limit" do
    review = Review.new(comment: "Great session!")
    assert_equal "Great session!", review.short_comment
  end

  test "short_comment truncates long comments" do
    long_comment = "a" * 200
    review = Review.new(comment: long_comment)
    assert_equal "a" * 150 + "...", review.short_comment
  end

  test "short_comment returns empty string for blank comment" do
    review = Review.new(comment: nil)
    assert_equal "", review.short_comment
  end

  # Association Tests
  test "should belong to reviewer" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 5
    )
    assert_respond_to review, :reviewer
    assert_equal @patient, review.reviewer
  end

  test "should belong to provider_profile" do
    review = Review.new(
      reviewer: @patient,
      provider_profile: @provider_profile,
      rating: 5
    )
    assert_respond_to review, :provider_profile
    assert_equal @provider_profile, review.provider_profile
  end
end
