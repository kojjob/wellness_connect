class Review < ApplicationRecord
  # Associations
  belongs_to :reviewer, class_name: "User"
  belongs_to :provider_profile

  # Validations
  validates :rating, presence: true,
                     numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, length: { maximum: 1000 }, allow_blank: true
  validates :reviewer_id, uniqueness: { scope: :provider_profile_id,
                                       message: "can only review a provider once" }

  validate :reviewer_is_not_provider
  validate :reviewer_had_completed_appointment

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(rating: :desc) }
  scope :with_comments, -> { where.not(comment: [ nil, "" ]) }

  # Instance methods
  def display_rating_stars
    "★" * rating + "☆" * (5 - rating)
  end

  def short_comment(length = 150)
    return "" if comment.blank?
    comment.length > length ? "#{comment[0...length]}..." : comment
  end

  private

  def reviewer_is_not_provider
    return unless reviewer_id && provider_profile&.user_id
    if reviewer_id == provider_profile.user_id
      errors.add(:reviewer, "cannot review their own profile")
    end
  end

  def reviewer_had_completed_appointment
    return unless reviewer_id && provider_profile&.user_id
    has_completed = Appointment.exists?(
      patient_id: reviewer_id,
      provider_id: provider_profile.user_id,
      status: :completed
    )
    unless has_completed
      errors.add(:base, "You must have a completed appointment to leave a review")
    end
  end
end
