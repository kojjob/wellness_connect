# WellnessConnect - Planning & Reference Documentation

**Last Updated:** January 5, 2025
**Status:** Active Development
**Purpose:** Planning documents, implementation roadmaps, data architecture, and seed data examples

---

## Table of Contents

### Planning & Implementation
1. [Complete Booking Flow Implementation Plan](#complete-booking-flow-implementation-plan)
   - Objectives & Current State
   - Implementation Roadmap (4 Phases)
   - Design System Specifications
   - Testing Strategy
   - Success Metrics
2. [Step-by-Step Implementation Guide](#step-by-step-implementation-guide)
   - Initial Application Setup
   - Authentication & Authorization
   - Model Generation
   - Feature Implementation

### Platform Architecture
3. [Data Models & Business Logic](#data-models--business-logic)
   - Core Models (8 models)
   - Model Attributes & Associations
   - Business Logic Workflows
   - Authorization & Permissions

### Seed Data & Examples
4. [Provider Profile Examples](#provider-profile-examples)
   - Available Profile Attributes (30+ fields)
   - Helper Methods
   - Example Files
   - Field Usage by Provider Type

---

# Complete Booking Flow Implementation Plan

**Feature Branch:** `feature/complete-booking-flow`
**Priority:** High (Core Revenue Feature)
**Estimated Time:** 2-3 weeks
**Status:** 🚧 In Progress

## 🎯 Objectives

Create a seamless, user-friendly appointment booking experience that:
1. Makes it easy for patients to find and book available time slots
2. Provides clear pricing and service information
3. Handles payment securely with Stripe
4. Sends confirmations and reminders
5. Allows easy management of appointments
6. Works flawlessly on mobile and desktop

## 📋 Current State Analysis

### ✅ What's Already Built:

**Backend:**
- ✅ Appointment model with status enum
- ✅ Appointments controller with create/cancel actions
- ✅ Availability model and controller
- ✅ Service model
- ✅ Payment model with Stripe integration
- ✅ Email notifications (AppointmentMailer)
- ✅ Notification system (in-app notifications)

**Frontend:**
- ✅ Basic booking widget on provider profile
- ✅ Appointment creation form with Stripe Elements
- ✅ Provider availability display

### 🔄 What Needs Enhancement:

**User Experience:**
- ❌ No calendar view for selecting dates
- ❌ Limited time slot selection (only shows next 5)
- ❌ No visual feedback during booking process
- ❌ No booking confirmation page
- ❌ No appointment management dashboard
- ❌ No rescheduling flow
- ❌ Limited mobile optimization

**Features:**
- ❌ No recurring appointments
- ❌ No waitlist for fully booked providers
- ❌ No appointment reminders (automated)
- ❌ No video call integration
- ❌ No pre-appointment questionnaire

## 🗺️ Implementation Roadmap

### Phase 1: Enhanced Booking Widget (Week 1)

#### 1.1 Calendar View Component
**Goal:** Visual calendar for date selection

**Tasks:**
- [ ] Create calendar Stimulus controller
- [ ] Design month view with available dates highlighted
- [ ] Add date picker with disabled past dates
- [ ] Show availability count per day
- [ ] Mobile-friendly calendar (swipe gestures)

**Files to Create/Modify:**
- `app/javascript/controllers/calendar_controller.js`
- `app/views/provider_profiles/sections/_booking_calendar.html.erb`
- `app/assets/stylesheets/components/calendar.css`

#### 1.2 Time Slot Selection
**Goal:** Better time slot browsing and selection

**Tasks:**
- [ ] Group time slots by date
- [ ] Show duration and price for each slot
- [ ] Add "Morning/Afternoon/Evening" filters
- [ ] Highlight selected slot
- [ ] Show timezone information

**Files to Modify:**
- `app/views/provider_profiles/sections/_booking_widget.html.erb`
- `app/javascript/controllers/booking_controller.js`

#### 1.3 Service Selection
**Goal:** Clear service options with details

**Tasks:**
- [ ] Service cards with descriptions
- [ ] Price comparison
- [ ] Duration display
- [ ] "What's included" details
- [ ] Add-on services (optional)

**Files to Create:**
- `app/views/provider_profiles/sections/_service_selector.html.erb`

### Phase 2: Booking Flow (Week 1-2)

#### 2.1 Multi-Step Booking Form
**Goal:** Guided booking process

**Steps:**
1. Select Service
2. Choose Date & Time
3. Enter Details (notes, preferences)
4. Review & Confirm
5. Payment
6. Confirmation

**Tasks:**
- [ ] Create step indicator component
- [ ] Build form wizard with Stimulus
- [ ] Add form validation per step
- [ ] Save progress (session storage)
- [ ] Back/Next navigation

**Files to Create:**
- `app/javascript/controllers/booking_wizard_controller.js`
- `app/views/appointments/_booking_steps.html.erb`
- `app/views/appointments/_step_1_service.html.erb`
- `app/views/appointments/_step_2_datetime.html.erb`
- `app/views/appointments/_step_3_details.html.erb`
- `app/views/appointments/_step_4_review.html.erb`
- `app/views/appointments/_step_5_payment.html.erb`

#### 2.2 Booking Confirmation Page
**Goal:** Clear confirmation with next steps

**Elements:**
- ✅ Success animation
- ✅ Appointment details card
- ✅ Add to calendar buttons (Google, Apple, Outlook)
- ✅ Provider contact info
- ✅ Preparation instructions
- ✅ Cancellation policy
- ✅ What happens next timeline

**Files to Create:**
- `app/views/appointments/confirmation.html.erb`
- `app/controllers/appointments_controller.rb` (add confirmation action)

### Phase 3: Appointment Management (Week 2)

#### 3.1 Patient Dashboard
**Goal:** Central hub for managing appointments

**Sections:**
- Upcoming Appointments (cards with countdown)
- Past Appointments (with review prompts)
- Cancelled Appointments
- Quick Actions (Book Again, Reschedule)

**Files to Create:**
- `app/views/dashboards/patient.html.erb`
- `app/controllers/dashboards_controller.rb`
- `app/javascript/controllers/dashboard_controller.js`

#### 3.2 Provider Dashboard
**Goal:** Manage schedule and clients

**Sections:**
- Today's Schedule (timeline view)
- Upcoming Appointments (calendar view)
- Appointment Requests (if approval needed)
- Revenue Summary
- Client Management

**Files to Create:**
- `app/views/dashboards/provider.html.erb`
- `app/views/dashboards/_schedule_timeline.html.erb`

#### 3.3 Appointment Detail Page
**Goal:** Full appointment information

**Elements:**
- Appointment status badge
- Service details
- Patient/Provider info
- Payment status
- Actions (Cancel, Reschedule, Join Video Call)
- Notes section
- History/Activity log

**Files to Create:**
- `app/views/appointments/show.html.erb`

#### 3.4 Rescheduling Flow
**Goal:** Easy appointment rescheduling

**Tasks:**
- [ ] Reschedule button on appointment detail
- [ ] Show available alternative slots
- [ ] Confirm new time
- [ ] Send notifications
- [ ] Update payment if price changed

**Files to Create:**
- `app/views/appointments/reschedule.html.erb`
- `app/controllers/appointments_controller.rb` (add reschedule action)

### Phase 4: Polish & Enhancements (Week 3)

#### 4.1 Loading & Empty States
- [ ] Skeleton loaders for calendar
- [ ] Loading spinner during booking
- [ ] Empty state for no appointments
- [ ] Error states with recovery

#### 4.2 Mobile Optimization
- [ ] Touch-friendly calendar
- [ ] Bottom sheet for time selection
- [ ] Sticky booking button
- [ ] Mobile payment optimization

#### 4.3 Accessibility
- [ ] Keyboard navigation for calendar
- [ ] Screen reader announcements
- [ ] Focus management in wizard
- [ ] ARIA labels everywhere

#### 4.4 Automated Reminders
- [ ] 24-hour reminder email
- [ ] 1-hour reminder (optional)
- [ ] SMS reminders (Twilio integration)
- [ ] Push notifications (PWA)

## 🎨 Design System

### Color Palette:
- **Primary:** Indigo-600 (#4F46E5)
- **Secondary:** Purple-600 (#9333EA)
- **Success:** Green-500 (#10B981)
- **Warning:** Yellow-500 (#F59E0B)
- **Error:** Red-500 (#EF4444)
- **Neutral:** Gray-50 to Gray-900

### Typography:
- **Headings:** Font-bold, text-2xl to text-4xl
- **Body:** Font-normal, text-base
- **Small:** Font-medium, text-sm

### Components:
- **Cards:** rounded-xl, shadow-lg
- **Buttons:** rounded-lg, px-6 py-3
- **Inputs:** rounded-lg, border-gray-300
- **Badges:** rounded-full, px-3 py-1

## 🧪 Testing Strategy

### Unit Tests:
- [ ] Appointment model validations
- [ ] Service model methods
- [ ] Availability logic

### Integration Tests:
- [ ] Booking flow end-to-end
- [ ] Payment processing
- [ ] Email delivery
- [ ] Notification creation

### System Tests:
- [ ] Calendar interaction
- [ ] Form wizard navigation
- [ ] Mobile booking flow
- [ ] Rescheduling flow

## 📊 Success Metrics

- **Booking Completion Rate:** > 80%
- **Average Booking Time:** < 3 minutes
- **Mobile Conversion:** > 60%
- **Payment Success Rate:** > 95%
- **User Satisfaction:** > 4.5/5

## 🚀 Deployment Checklist

- [ ] All tests passing
- [ ] Stripe webhooks configured
- [ ] Email templates tested
- [ ] Mobile responsive verified
- [ ] Accessibility audit passed
- [ ] Performance optimized (< 3s load)
- [ ] Error tracking configured (Sentry)
- [ ] Analytics events set up

---

# Step-by-Step Implementation Guide

**Original Comprehensive Prompt for Building the Telehealth & Wellness Platform**

## 1. Project Goal & Tech Stack

**Primary Goal:** Develop a complete Ruby on Rails 8 application, "WellnessConnect," that serves as a marketplace for patients to find and book virtual appointments with wellness providers.

**Core Technologies:**
- **Backend:** Ruby on Rails 8
- **Database:** PostgreSQL
- **Frontend:** Hotwire (Turbo & Stimulus), TailwindCSS
- **Authentication:** Devise gem
- **Payments:** Stripe gem
- **File Uploads:** Active Storage

## 2. Core Features for MVP

- **User Authentication:** Secure sign-up and login for Patients, Providers, and Admins using Devise. Role management is critical.
- **Provider Profiles:** Providers can create and manage their public-facing profiles, detailing their specialty, credentials, and bio.
- **Service Management:** Providers can list, define, and price the services they offer (e.g., "45-Minute Coaching Session").
- **Availability Management:** Providers can set and manage their weekly availability for appointments.
- **Patient Booking:** Patients can browse providers, view their services and availability, and book an appointment.
- **Dashboards:** Separate, simple dashboards for patients and providers to view their upcoming and past appointments.

## 3. Data Schema

The complete data schema, including all models, attributes, and associations, is defined in the [Data Models & Business Logic](#data-models--business-logic) section below. You must adhere strictly to this data model to ensure relational integrity.

## 4. Step-by-Step Implementation Plan

Please proceed sequentially through the following steps, confirming the completion of each major stage.

### Step 1: Initial Application Setup
1. Generate a new Rails 8 application:
   ```bash
   rails new wellness_connect --database=postgresql -c tailwind
   ```
2. Navigate into the `wellness_connect` directory.
3. Add necessary gems to the `Gemfile`:
   ```ruby
   gem 'devise'
   gem 'pundit' # For authorization
   gem 'stripe'
   ```
4. Run `bundle install` and create the database: `rails db:create`.

### Step 2: Authentication & Authorization
1. Set up Devise for the `User` model.
2. Add a `role` column to the `users` table (enum: `patient`, `provider`, `admin`).
3. Set up Pundit for authorization, creating policies for each model to enforce role-based access (e.g., only providers can edit their own profiles).

### Step 3: Model & Migration Generation
1. Using the data schema as a reference, generate all required models and their corresponding migrations. For example:
   ```bash
   rails g model ProviderProfile user:references specialty:string bio:text
   rails g model Service provider_profile:references name:string description:text duration_minutes:integer price:decimal
   # ... and so on for all other models.
   ```
2. Implement all `has_many`, `belongs_to`, etc., associations in the `app/models/*.rb` files as specified in the schema.
3. Run `rails db:migrate`.

### Step 4: Provider-Side Features (Controllers & Views)
1. Implement full CRUD functionality for `ProviderProfiles`.
2. Implement full CRUD functionality for `Services`, nested under the provider's profile.
3. Implement full CRUD functionality for `Availabilities`, allowing providers to manage their schedules.
4. Create a provider-specific dashboard to view their appointments.

### Step 5: Patient-Side Features (Controllers & Views)
1. Create a public-facing controller/view to browse all providers.
2. Implement the appointment booking workflow. This should be a multi-step process handled by an `AppointmentsController`:
   - Select a provider -> View services & availability -> Select a time -> Confirm & Pay.
   - Use Turbo Frames and Stimulus to create a smooth, single-page experience for the booking process.
3. Create a patient-specific dashboard to view their upcoming and past appointments.

### Step 6: Styling
- Throughout the development process, use TailwindCSS utility classes to style all views. Aim for a clean, modern, and responsive design.

---

# Data Models & Business Logic

**Telehealth & Wellness Platform - Complete Data Architecture**

This section defines the data models, attributes, associations, and core business logic for the WellnessConnect platform, designed for Ruby on Rails 8 with PostgreSQL.

## Core Models

### 1. `User`
The central model representing any individual interacting with the platform.

**Attributes:**
- `id` (Primary Key)
- `email` (string, unique, indexed)
- `password_digest` (string)
- `first_name` (string)
- `last_name` (string)
- `role` (enum: `patient`, `provider`, `admin`, `super_admin`, default: `patient`)
- `time_zone` (string, default: 'UTC')
- `created_at`, `updated_at`

**Associations:**
- `has_one :provider_profile, dependent: :destroy`
- `has_one :patient_profile, dependent: :destroy`
- `has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'`
- `has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'`
- `has_many :appointments_as_patient, class_name: 'Appointment', foreign_key: 'patient_id'`
- `has_many :appointments_as_provider, class_name: 'Appointment', foreign_key: 'provider_id'`
- `has_many :payments_made, class_name: 'Payment', foreign_key: 'payer_id'`

### 2. `ProviderProfile`
Stores detailed information for users who are service providers (coaches, therapists, etc.).

**Attributes:**
- `id` (Primary Key)
- `user_id` (Foreign Key to `User`, unique, indexed)
- `specialty` (string, e.g., "Nutrition", "Mental Health")
- `bio` (text)
- `credentials` (text, e.g., "Certified Nutritionist, PhD")
- `consultation_rate` (decimal, for per-session billing)
- `created_at`, `updated_at`

**Associations:**
- `belongs_to :user`
- `has_many :services, dependent: :destroy`
- `has_many :availabilities, dependent: :destroy`

### 3. `PatientProfile`
Stores health-related information for users who are patients.

**Attributes:**
- `id` (Primary Key)
- `user_id` (Foreign Key to `User`, unique, indexed)
- `date_of_birth` (date)
- `health_goals` (text)
- `medical_history_summary` (text, encrypted)
- `created_at`, `updated_at`

**Associations:**
- `belongs_to :user`

### 4. `Service`
A specific offering by a provider.

**Attributes:**
- `id` (Primary Key)
- `provider_profile_id` (Foreign Key to `ProviderProfile`, indexed)
- `name` (string, e.g., "60-Minute Wellness Coaching")
- `description` (text)
- `duration_minutes` (integer)
- `price` (decimal)
- `is_active` (boolean, default: true)
- `created_at`, `updated_at`

**Associations:**
- `belongs_to :provider_profile`
- `has_many :appointments`

### 5. `Availability`
Time slots when a provider is available for appointments.

**Attributes:**
- `id` (Primary Key)
- `provider_profile_id` (Foreign Key to `ProviderProfile`, indexed)
- `start_time` (datetime)
- `end_time` (datetime)
- `is_booked` (boolean, default: false)
- `created_at`, `updated_at`

**Associations:**
- `belongs_to :provider_profile`

### 6. `Appointment`
A scheduled meeting between a patient and a provider.

**Attributes:**
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

**Associations:**
- `belongs_to :patient, class_name: 'User'`
- `belongs_to :provider, class_name: 'User'`
- `belongs_to :service`
- `has_one :payment, dependent: :destroy`
- `has_one :consultation_note, dependent: :destroy`

### 7. `Payment`
Records a financial transaction for an appointment or subscription.

**Attributes:**
- `id` (Primary Key)
- `payer_id` (Foreign Key to `User`, indexed)
- `appointment_id` (Foreign Key to `Appointment`, nullable, indexed)
- `amount` (decimal)
- `currency` (string, default: "USD")
- `status` (enum: `pending`, `succeeded`, `failed`)
- `stripe_payment_intent_id` (string, indexed)
- `paid_at` (datetime)
- `created_at`, `updated_at`

**Associations:**
- `belongs_to :payer, class_name: 'User'`
- `belongs_to :appointment, optional: true`

### 8. `ConsultationNote`
Private notes a provider takes during an appointment.

**Attributes:**
- `id` (Primary Key)
- `appointment_id` (Foreign Key to `Appointment`, unique, indexed)
- `content` (text, encrypted)
- `created_at`, `updated_at`

**Associations:**
- `belongs_to :appointment`

## Core Business Logic

### 1. Provider Onboarding:
- A user signs up and changes their role to `provider`.
- This prompts the creation of a `ProviderProfile`.
- The provider must fill out their profile (`specialty`, `credentials`) before they can offer services.

### 2. Scheduling & Availability:
- Providers create `Availability` records for the times they are open. This can be a recurring job that generates slots for future weeks.
- When a patient views a provider's schedule, the application queries the `Availability` model for unbooked slots (`is_booked: false`) in the future.

### 3. Booking Workflow:
- A patient selects an available slot and a `Service`.
- An `Appointment` is created with `status: 'scheduled'`.
- The corresponding `Availability` record is marked as `is_booked: true`.
- A `Payment` record is created with `status: 'pending'` and a Stripe Payment Intent is generated.
- A background job should be scheduled to release the `Availability` slot if the payment is not completed within a certain time (e.g., 15 minutes).

### 4. Cancellations:
- Patients or providers can cancel an appointment. The `status` is updated and `cancellation_reason` is logged.
- Business rules will determine refund eligibility based on how far in advance the cancellation occurs (e.g., full refund if > 24 hours).

### 5. Video Sessions:
- When an appointment is about to start, a unique `video_session_id` is generated (e.g., using a service like Daily.co or Twilio Video).
- This ID is used to create a unique video room for the patient and provider.

### 6. Roles & Permissions:
- Use a library like Pundit or CanCanCan.
- `Providers` can manage their own profiles, services, and availability. They can view appointments and create `ConsultationNote`s for them.
- `Patients` can manage their own profiles and book/cancel appointments. They can only view their own appointment data.
- `Admins` have oversight over all data for support and moderation.

---

# Provider Profile Examples

**Comprehensive Guide to Creating Rich Provider Profiles**

This section contains detailed examples of how to create comprehensive provider profiles using all available `ProviderProfile` model attributes.

## Available Provider Profile Attributes

### Core Information (Required)
- **`specialty`** (string) - Professional specialty/category
  - Examples: "Business Coaching", "Naturopathic Medicine", "Software Engineering"
- **`bio`** (text) - Comprehensive professional background and approach
  - Minimum 50 characters, maximum 2000 characters
  - Should include experience, approach, and value proposition
- **`credentials`** (text) - Professional certifications, licenses, degrees
  - Examples: "MBA, Certified Coach", "ND, Licensed Naturopathic Doctor"
- **`consultation_rate`** (decimal) - Default hourly or per-session rate in USD
  - Must be greater than 0

### Education & Experience
- **`education`** (text) - Degrees, schools, specialized training
  - Example: "M.S. Computer Science, Stanford University; B.S. Engineering, MIT"
- **`certifications`** (text) - Detailed certifications and professional credentials
  - Example: "AWS Certified Solutions Architect, Certified Scrum Master"
- **`years_of_experience`** (integer) - Number of years in practice
  - Must be >= 0

### New Comprehensive Fields (Added 2025-01-05)

#### `areas_of_expertise` (text, comma-separated)
Multiple specialization areas within the provider's field. Stored as comma-separated text, accessible via `areas_of_expertise_array` helper method.

**Example (Software Consultant):**
```ruby
areas_of_expertise: "System Architecture Design, Cloud Infrastructure, Backend Development, API Design, Database Optimization, DevOps & CI/CD"
```

**Example (Health Practitioner):**
```ruby
areas_of_expertise: "Chronic Disease Management, Digestive Health, Hormone Balance, Autoimmune Conditions, Nutritional Therapy"
```

#### `treatment_modalities` (text, comma-separated)
Treatment methods and therapeutic approaches - primarily for health practitioners. Accessible via `treatment_modalities_array` helper method.

**Example (Naturopathic Doctor):**
```ruby
treatment_modalities: "Clinical Nutrition, Botanical Medicine, Homeopathy, Acupuncture, IV Nutrient Therapy, Bio-identical Hormone Replacement"
```

**Note:** Non-health providers can leave this field empty or repurpose for methodologies/approaches.

#### `philosophy` (text)
Provider's professional philosophy, approach, or treatment principles. Free-form text field for expressing core values and methods.

**Example (Consultant):**
```ruby
philosophy: "I believe in pragmatic solutions that balance technical excellence with business realities. My consulting approach emphasizes practical solutions, education-first mindset, and data-driven decisions."
```

**Example (Health Practitioner):**
```ruby
philosophy: "I believe in treating the whole person, not just symptoms. My approach follows the six principles of naturopathic medicine: First Do No Harm, The Healing Power of Nature, Identify Root Causes, Doctor as Teacher, Treat the Whole Person, and Prevention is the Best Cure."
```

#### `session_formats` (text, comma-separated)
Available consultation formats and delivery methods. Accessible via `session_formats_array` helper method.

**Examples:**
```ruby
# Consultant
session_formats: "Video Consultation (Zoom/Google Meet), Screen Sharing for Code Review, Asynchronous Code Review via GitHub, In-Person (Bay Area)"

# Health Practitioner
session_formats: "In-Person Consultation, Telemedicine Video Visits, Phone Consultation, Hybrid Care Plans, Group Workshops"
```

#### `industries_served` (text, comma-separated)
Industries or market segments the provider serves - primarily for consultants. Accessible via `industries_served_array` helper method.

**Example (Business Consultant):**
```ruby
industries_served: "SaaS & Cloud Services, E-commerce, FinTech, HealthTech, EdTech, Media Platforms, B2B Enterprise Software"
```

**Note:** Health practitioners can use this for patient types or leave empty.

### Contact & Social Media
- **`phone`** (string) - Contact phone number with format validation
- **`website`** (string) - Provider's professional website (URL validation)
- **`linkedin_url`** (string) - LinkedIn profile URL
- **`twitter_url`** (string) - Twitter/X profile URL
- **`facebook_url`** (string) - Facebook page URL
- **`instagram_url`** (string) - Instagram profile URL

### Location
- **`office_address`** (text) - Physical office address or "Remote" designation
- **`languages`** (text, comma-separated) - Languages spoken
  - Accessible via `languages_array` helper method
  - Example: "English, Spanish, Mandarin Chinese"

### Metrics (Auto-Calculated)
- **`average_rating`** (decimal) - Calculated from reviews
- **`total_reviews`** (integer) - Count of reviews

### Active Storage Attachments
- **`avatar`** - Profile photo (max 5MB, JPEG/PNG/WebP)
- **`gallery_images`** - Portfolio images (max 10MB each)
- **`gallery_videos`** - Portfolio videos (max 100MB each)
- **`gallery_audio`** - Audio samples (max 50MB each)
- **`documents`** - PDF credentials, certificates (max 20MB each)

## Helper Methods

The `ProviderProfile` model provides array helper methods for comma-separated fields:

```ruby
provider_profile.languages_array
# => ["English", "Spanish", "Mandarin Chinese"]

provider_profile.areas_of_expertise_array
# => ["System Architecture Design", "Cloud Infrastructure", "Backend Development"]

provider_profile.treatment_modalities_array
# => ["Clinical Nutrition", "Botanical Medicine", "Homeopathy"]

provider_profile.session_formats_array
# => ["Video Consultation (Zoom/Google Meet)", "In-Person Consultation"]

provider_profile.industries_served_array
# => ["SaaS & Cloud Services", "E-commerce", "FinTech"]
```

## Example Files

This directory contains two comprehensive examples:

### 1. `software_engineer_profile_example.rb`
Demonstrates a complete Software Engineering & Data Consultant profile including:
- Technical expertise areas (10 areas listed)
- Industries served (8 industries)
- Session formats (5 formats including screen sharing and async code review)
- Professional philosophy for consultants
- 4 service offerings with detailed descriptions
- 2 weeks of availability slots

### 2. `naturopathic_practitioner_profile_example.rb`
Demonstrates a complete Naturopathic Health Practitioner profile including:
- Health-focused expertise areas (10 areas)
- Treatment modalities (10 therapeutic approaches)
- Naturopathic medicine philosophy with six core principles
- Session formats including telemedicine and in-person
- 5 service offerings (consultation types with varying durations)
- 2 weeks of availability slots (4-day work week)

## Running the Examples

To create sample provider profiles, run the example files from Rails console:

```bash
bin/rails console

# Load and execute the Software Engineer profile example
load 'db/seeds/profile_examples/software_engineer_profile_example.rb'

# Load and execute the Naturopathic Practitioner profile example
load 'db/seeds/profile_examples/naturopathic_practitioner_profile_example.rb'
```

## Creating Your Own Provider Profiles

When creating provider profiles, consider:

1. **Required fields:** specialty, bio (50-2000 chars), credentials, consultation_rate
2. **Use comma-separated values** for array fields (languages, areas_of_expertise, etc.)
3. **Customize to provider type:**
   - Consultants: Focus on `industries_served` and `areas_of_expertise`
   - Health practitioners: Use `treatment_modalities` and health-focused expertise
   - All types: Include `philosophy` and `session_formats`
4. **Add services:** Create 3-5 service offerings with clear descriptions and pricing
5. **Set availability:** Generate availability slots based on provider's schedule
6. **Validate URLs:** Ensure all social media and website URLs are properly formatted

## Field Usage by Provider Type

| Field | Consultants | Health Practitioners | Other Professionals |
|-------|-------------|---------------------|---------------------|
| `specialty` | ✅ Required | ✅ Required | ✅ Required |
| `bio` | ✅ Required | ✅ Required | ✅ Required |
| `credentials` | ✅ Required | ✅ Required | ✅ Required |
| `areas_of_expertise` | ✅ Recommended | ✅ Recommended | ✅ Recommended |
| `treatment_modalities` | ❌ Skip | ✅ Required | ⚠️ Optional (can repurpose) |
| `industries_served` | ✅ Recommended | ⚠️ Optional | ✅ Recommended |
| `philosophy` | ✅ Recommended | ✅ Recommended | ✅ Recommended |
| `session_formats` | ✅ Required | ✅ Required | ✅ Required |

## Database Schema

The migration `20251005012911_add_comprehensive_fields_to_provider_profiles.rb` added:

```ruby
add_column :provider_profiles, :areas_of_expertise, :text
add_column :provider_profiles, :treatment_modalities, :text
add_column :provider_profiles, :philosophy, :text
add_column :provider_profiles, :session_formats, :text
add_column :provider_profiles, :industries_served, :text
```

All new fields are nullable, allowing gradual adoption and flexibility across different provider types.

---

**End of REFERENCE.md**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
