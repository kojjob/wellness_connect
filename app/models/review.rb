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
end
