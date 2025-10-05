class ProviderProfile < ApplicationRecord
  belongs_to :user

  has_many :services, dependent: :destroy
  has_many :availabilities, dependent: :destroy

  # Active Storage attachments
  has_one_attached :avatar
  has_many_attached :gallery_images
  has_many_attached :gallery_videos
  has_many_attached :gallery_audio
  has_many_attached :documents

  # Helper methods
  def full_name
    user.full_name
  end

  def average_rating
    # Return 5.0 as default since we don't have reviews yet
    5.0
  end

  def display_rating
    average_rating.round(1)
  end

  def total_reviews
    # Return 0 since we don't have reviews yet
    0
  end

  def has_social_media?
    linkedin_url.present? || twitter_url.present? || facebook_url.present? || instagram_url.present?
  end

  def languages_array
    languages.present? ? languages.split(",").map(&:strip) : []
  end

  def areas_of_expertise_array
    areas_of_expertise.present? ? areas_of_expertise.split(",").map(&:strip) : []
  end

  def treatment_modalities_array
    treatment_modalities.present? ? treatment_modalities.split(",").map(&:strip) : []
  end

  def session_formats_array
    session_formats.present? ? session_formats.split(",").map(&:strip) : []
  end

  def industries_served_array
    industries_served.present? ? industries_served.split(",").map(&:strip) : []
  end

  def total_media_count
    gallery_images.count + gallery_videos.count + gallery_audio.count + documents.count
  end
end
