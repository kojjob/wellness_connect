# Telehealth & Wellness Platform - Data & Logic Plan

This document outlines the data models, attributes, associations, and core business logic for the Telehealth & Wellness Platform, designed for a Ruby on Rails 8 application using PostgreSQL.

---

## Core Models

### 1. `User`
The central model representing any individual interacting with the platform.

- **Attributes:**
  - `id` (Primary Key)
  - `email` (string, unique, indexed)
  - `password_digest` (string)
  - `first_name` (string)
  - `last_name` (string)
  - `role` (enum: `patient`, `provider`, `admin`, default: `patient`)
  - `time_zone` (string, default: 'UTC')
  - `created_at`, `updated_at`

- **Associations:**
  - `has_one :provider_profile, dependent: :destroy`
  - `has_one :patient_profile, dependent: :destroy`
  - `has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'`
  - `has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'`
  - `has_many :appointments_as_patient, class_name: 'Appointment', foreign_key: 'patient_id'`
  - `has_many :appointments_as_provider, class_name: 'Appointment', foreign_key: 'provider_id'`
  - `has_many :payments_made, class_name: 'Payment', foreign_key: 'payer_id'`

### 2. `ProviderProfile`
Stores detailed information for users who are service providers (coaches, therapists, etc.).

- **Attributes:**
  - `id` (Primary Key)
  - `user_id` (Foreign Key to `User`, unique, indexed)
  - `specialty` (string, e.g., "Nutrition", "Mental Health")
  - `bio` (text)
  - `credentials` (text, e.g., "Certified Nutritionist, PhD")
  - `consultation_rate` (decimal, for per-session billing)
  - `created_at`, `updated_at`

- **Associations:**
  - `belongs_to :user`
  - `has_many :services, dependent: :destroy`
  - `has_many :availabilities, dependent: :destroy`

### 3. `PatientProfile`
Stores health-related information for users who are patients.

- **Attributes:**
  - `id` (Primary Key)
  - `user_id` (Foreign Key to `User`, unique, indexed)
  - `date_of_birth` (date)
  - `health_goals` (text)
  - `medical_history_summary` (text, encrypted)
  - `created_at`, `updated_at`

- **Associations:**
  - `belongs_to :user`

### 4. `Service`
A specific offering by a provider.

- **Attributes:**
  - `id` (Primary Key)
  - `provider_profile_id` (Foreign Key to `ProviderProfile`, indexed)
  - `name` (string, e.g., "60-Minute Wellness Coaching")
  - `description` (text)
  - `duration_minutes` (integer)
  - `price` (decimal)
  - `is_active` (boolean, default: true)
  - `created_at`, `updated_at`

- **Associations:**
  - `belongs_to :provider_profile`
  - `has_many :appointments`

### 5. `Availability`
Time slots when a provider is available for appointments.

- **Attributes:**
  - `id` (Primary Key)
  - `provider_profile_id` (Foreign Key to `ProviderProfile`, indexed)
  - `start_time` (datetime)
  - `end_time` (datetime)
  - `is_booked` (boolean, default: false)
  - `created_at`, `updated_at`

- **Associations:**
  - `belongs_to :provider_profile`

### 6. `Appointment`
A scheduled meeting between a patient and a provider.

- **Attributes:**
  - `id` (Primary Key)
  - `patient_id` (Foreign Key to `User`, indexed)
  - `provider_id` (Foreign Key to `User`, indexed)
  - `service_id` (Foreign Key to `Service`, indexed)
  - `start_time` (datetime)
  - `end_time` (datetime)
  - `status` (enum: `scheduled`, `completed`, `cancelled_by_patient`, `cancelled_by_provider`, `no_show`)
  - `cancellation_reason` (text, optional)
  - `video_session_id` (string, for video call integration)
  - `created_at`, `updated_at`

- **Associations:**
  - `belongs_to :patient, class_name: 'User'`
  - `belongs_to :provider, class_name: 'User'`
  - `belongs_to :service`
  - `has_one :payment, dependent: :destroy`
  - `has_one :consultation_note, dependent: :destroy`

### 7. `Payment`
Records a financial transaction for an appointment or subscription.

- **Attributes:**
  - `id` (Primary Key)
  - `payer_id` (Foreign Key to `User`, indexed)
  - `appointment_id` (Foreign Key to `Appointment`, nullable, indexed)
  - `amount` (decimal)
  - `currency` (string, default: "USD")
  - `status` (enum: `pending`, `succeeded`, `failed`)
  - `stripe_payment_intent_id` (string, indexed)
  - `paid_at` (datetime)
  - `created_at`, `updated_at`

- **Associations:**
  - `belongs_to :payer, class_name: 'User'`
  - `belongs_to :appointment, optional: true`

### 8. `ConsultationNote`
Private notes a provider takes during an appointment.

- **Attributes:**
  - `id` (Primary Key)
  - `appointment_id` (Foreign Key to `Appointment`, unique, indexed)
  - `content` (text, encrypted)
  - `created_at`, `updated_at`

- **Associations:**
  - `belongs_to :appointment`

---

## Core Business Logic

1.  **Provider Onboarding:**
    - A user signs up and changes their role to `provider`.
    - This prompts the creation of a `ProviderProfile`.
    - The provider must fill out their profile (`specialty`, `credentials`) before they can offer services.

2.  **Scheduling & Availability:**
    - Providers create `Availability` records for the times they are open. This can be a recurring job that generates slots for future weeks.
    - When a patient views a provider's schedule, the application queries the `Availability` model for unbooked slots (`is_booked: false`) in the future.

3.  **Booking Workflow:**
    - A patient selects an available slot and a `Service`.
    - An `Appointment` is created with `status: 'scheduled'`.
    - The corresponding `Availability` record is marked as `is_booked: true`.
    - A `Payment` record is created with `status: 'pending'` and a Stripe Payment Intent is generated.
    - A background job should be scheduled to release the `Availability` slot if the payment is not completed within a certain time (e.g., 15 minutes).

4.  **Cancellations:**
    - Patients or providers can cancel an appointment. The `status` is updated and `cancellation_reason` is logged.
    - Business rules will determine refund eligibility based on how far in advance the cancellation occurs (e.g., full refund if > 24 hours).

5.  **Video Sessions:**
    - When an appointment is about to start, a unique `video_session_id` is generated (e.g., using a service like Daily.co or Twilio Video).
    - This ID is used to create a unique video room for the patient and provider.

6.  **Roles & Permissions:**
    - Use a library like Pundit or CanCanCan.
    - `Providers` can manage their own profiles, services, and availability. They can view appointments and create `ConsultationNote`s for them.
    - `Patients` can manage their own profiles and book/cancel appointments. They can only view their own appointment data.
    - `Admins` have oversight over all data for support and moderation.
