class ConsultationNote < ApplicationRecord
  belongs_to :appointment

  # Validations
  validates :appointment_id, presence: true, uniqueness: { message: "can only have one consultation note" }
  validates :content, presence: true, length: { minimum: 10, maximum: 10000 }

  # Encrypt sensitive medical content
  encrypts :content

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def summary(length = 200)
    return "" if content.blank?
    content.length > length ? "#{content[0...length]}..." : content
  end
end
