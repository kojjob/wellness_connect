class Service < ApplicationRecord
  belongs_to :provider_profile

  has_many :appointments, dependent: :destroy
end
