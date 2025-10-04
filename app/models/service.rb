class Service < ApplicationRecord
  belongs_to :provider_profile

  has_many :appointments, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
