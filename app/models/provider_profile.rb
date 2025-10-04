class ProviderProfile < ApplicationRecord
  belongs_to :user

  has_many :services, dependent: :destroy
  has_many :availabilities, dependent: :destroy

  # Active Storage attachments
  has_one_attached :avatar
  has_many_attached :gallery_images
  has_many_attached :gallery_videos
  has_many_attached :gallery_audio
  has_many_attached :documents # For PDFs, certifications, etc.

  # Validations
  validates :specialty, presence: true
  validates :bio, presence: true, length: { minimum: 50, maximum: 2000 }
  validates :consultation_rate, presence: true, numericality: { greater_than: 0 }
  validates :years_of_experience, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :phone, format: { with: /\A[\d\s\-\+\(\)]+\z/, allow_blank: true }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :linkedin_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :twitter_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :facebook_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :instagram_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # Custom validations for Active Storage attachments
  validate :avatar_validation
  validate :gallery_images_validation
  validate :gallery_videos_validation
  validate :gallery_audio_validation
  validate :documents_validation

  private

  def avatar_validation
    return unless avatar.attached?

    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end

    unless avatar.blob.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
      errors.add(:avatar, "must be a JPEG, PNG, or WebP image")
    end
  end

  def gallery_images_validation
    return unless gallery_images.attached?

    gallery_images.each do |image|
      if image.blob.byte_size > 10.megabytes
        errors.add(:gallery_images, "must be less than 10MB each")
      end

      unless image.blob.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
        errors.add(:gallery_images, "must be JPEG, PNG, or WebP images")
      end
    end
  end

  def gallery_videos_validation
    return unless gallery_videos.attached?

    gallery_videos.each do |video|
      if video.blob.byte_size > 100.megabytes
        errors.add(:gallery_videos, "must be less than 100MB each")
      end

      unless video.blob.content_type.in?(%w[video/mp4 video/quicktime video/x-msvideo])
        errors.add(:gallery_videos, "must be MP4, MOV, or AVI videos")
      end
    end
  end

  def gallery_audio_validation
    return unless gallery_audio.attached?

    gallery_audio.each do |audio|
      if audio.blob.byte_size > 50.megabytes
        errors.add(:gallery_audio, "must be less than 50MB each")
      end

      unless audio.blob.content_type.in?(%w[audio/mpeg audio/mp3 audio/wav audio/ogg])
        errors.add(:gallery_audio, "must be MP3, WAV, or OGG audio files")
      end
    end
  end

  def documents_validation
    return unless documents.attached?

    documents.each do |doc|
      if doc.blob.byte_size > 20.megabytes
        errors.add(:documents, "must be less than 20MB each")
      end

      unless doc.blob.content_type.in?(%w[application/pdf])
        errors.add(:documents, "must be PDF files")
      end
    end
  end

  public

  # Helper methods
  def full_name
    user.full_name
  end

  def display_rating
    average_rating&.round(1) || 0.0
  end

  def has_social_media?
    linkedin_url.present? || twitter_url.present? || facebook_url.present? || instagram_url.present?
  end

  def languages_array
    languages.present? ? languages.split(",").map(&:strip) : []
  end

  def total_media_count
    gallery_images.count + gallery_videos.count + gallery_audio.count + documents.count
  end
end
