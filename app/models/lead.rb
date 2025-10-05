class Lead < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :set_defaults

  scope :subscribed, -> { where(subscribed: true) }
  scope :recent, -> { order(created_at: :desc) }

  private

  def set_defaults
    self.subscribed = true if subscribed.nil?
    self.source ||= 'landing_page'
  end
end

