class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum :role, { patient: 0, provider: 1, admin: 2 }, default: :patient

  # Associations
  has_one :provider_profile, dependent: :destroy
  has_one :patient_profile, dependent: :destroy
  has_many :appointments_as_patient, class_name: "Appointment", foreign_key: "patient_id", dependent: :destroy
  has_many :appointments_as_provider, class_name: "Appointment", foreign_key: "provider_id", dependent: :destroy
  has_many :payments_made, class_name: "Payment", foreign_key: "payer_id", dependent: :destroy
end
