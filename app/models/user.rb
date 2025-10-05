class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  # Include Analytics concern for provider metrics
  include Analytics

  # Enums
  # Role hierarchy: patient < provider < admin < super_admin
  # super_admin: Full system access including user creation and management
  # admin: Can view and manage content but cannot create users
  # provider: Can offer services and manage appointments
  # patient: Can book appointments and access services
  enum :role, { patient: 0, provider: 1, admin: 2, super_admin: 3 }, default: :patient

  # Associations
  has_one :provider_profile, dependent: :destroy
  has_one :patient_profile, dependent: :destroy
  has_many :appointments_as_patient, class_name: "Appointment", foreign_key: "patient_id", dependent: :destroy
  has_many :appointments_as_provider, class_name: "Appointment", foreign_key: "provider_id", dependent: :destroy
  has_many :payments_made, class_name: "Payment", foreign_key: "payer_id", dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :reviews, foreign_key: "reviewer_id", dependent: :destroy

  # Active Storage
  has_one_attached :avatar

  # Scopes for filtering users by status
  scope :active, -> { where(suspended_at: nil, blocked_at: nil) }
  scope :suspended, -> { where.not(suspended_at: nil) }
  scope :blocked, -> { where.not(blocked_at: nil) }
  scope :inactive, -> { where.not(suspended_at: nil).or(where.not(blocked_at: nil)) }

  scope :search, ->(query) {
    return all if query.blank?

    where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%")
  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip.presence || email
  end

  # Status query methods
  def active?
    suspended_at.nil? && blocked_at.nil?
  end

  def suspended?
    suspended_at.present?
  end

  def blocked?
    blocked_at.present?
  end

  def inactive?
    suspended? || blocked?
  end

  # Status change methods
  def suspend!(reason = nil)
    update!(
      suspended_at: Time.current,
      status_reason: reason
    )
  end

  def unsuspend!
    update!(
      suspended_at: nil,
      status_reason: nil
    )
  end

  def block!(reason = nil)
    update!(
      blocked_at: Time.current,
      status_reason: reason
    )
  end

  def unblock!
    update!(
      blocked_at: nil,
      status_reason: nil
    )
  end

  # Helper methods for UI
  def status
    return "suspended" if suspended?
    return "blocked" if blocked?

    "active"
  end

  def status_badge_class
    case status
    when "active"
      "bg-green-100 text-green-800"
    when "suspended"
      "bg-yellow-100 text-yellow-800"
    when "blocked"
      "bg-red-100 text-red-800"
    end
  end

  # Devise integration - prevent suspended/blocked users from logging in
  def active_for_authentication?
    super && active?
  end

  def inactive_message
    if suspended?
      :suspended
    elsif blocked?
      :blocked
    else
      super
    end
  end
end
