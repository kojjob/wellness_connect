# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**WellnessConnect** is a professional services marketplace platform that connects clients with qualified service providers for virtual consultations and sessions. The platform enables:

- **Clients**: Browse service providers, view services/availability, book sessions, manage their profiles
- **Service Providers**: Create professional profiles, list services, manage availability, conduct sessions, take notes
- **Admins**: Oversee platform operations, support, and moderation

**Service Provider Types**: The platform supports various qualified professionals including:
- Wellness coaches, therapists, nutritionists
- Business consultants, career coaches
- Legal advisors, financial planners
- Tutors, mentors, trainers
- Any professional offering time-based consultation services

This is an MVP focusing on core booking and session workflow with integrated payment processing via Stripe.

## Technology Stack

- **Framework**: Ruby on Rails 8.1.0.beta1 (edge Rails with modern features)
- **Database**: PostgreSQL
- **Authentication**: Devise gem (user sign-up, login, password management)
- **Authorization**: Pundit gem (role-based access control via policy objects)
- **Payment Processing**: Stripe gem (payment intents, refunds)
- **File Uploads**: Active Storage (for profile photos, documents, credentials)
- **Frontend**:
  - Hotwire (Turbo Frames + Turbo Streams for SPA-like experience)
  - Stimulus (JavaScript framework for behavior)
  - TailwindCSS (utility-first styling)
  - Importmap (JavaScript module management)
- **Background Jobs**: Solid Queue (Rails 8 database-backed job processing)
- **Caching**: Solid Cache (Rails 8 database-backed caching)
- **WebSockets**: Solid Cable (Rails 8 database-backed Action Cable)
- **Deployment**: Kamal with Thruster (containerized deployment)

## Data Architecture & Domain Model

### Core Entities

#### 1. User (Central Identity Model)
- **Role System**: Single enum role (`patient`, `provider`, `admin`) - NOT multiple boolean flags
  - Note: "patient" terminology used for database/code, but represents "client" in UI/business context
- **Polymorphic Profiles**: Based on role, users have either PatientProfile (client profile) OR ProviderProfile
- **Attributes**: email, password_digest, first_name, last_name, role, time_zone
- **Key Associations**:
  - `has_one :provider_profile` (if role is provider)
  - `has_one :patient_profile` (if role is patient/client)
  - `has_many :appointments_as_patient` (sessions where they're the client)
  - `has_many :appointments_as_provider` (sessions where they're the provider)
  - `has_many :payments_made` (as payer)
  - `has_many :sent_messages`, `has_many :received_messages` (future messaging feature)

#### 2. ProviderProfile
- **Purpose**: Extended information for users with provider role (service professionals)
- **Attributes**:
  - `specialty` - Professional specialty/category (e.g., "Business Coaching", "Legal Consultation", "Nutrition")
  - `bio` - Professional background and approach
  - `credentials` - Certifications, licenses, degrees (e.g., "MBA, Certified Business Coach", "Licensed Attorney")
  - `consultation_rate` - Default hourly or per-session rate
- **Associations**:
  - `belongs_to :user`
  - `has_many :services` (offerings like "60-min business strategy session")
  - `has_many :availabilities` (time slots when provider is available)

#### 3. PatientProfile
- **Purpose**: Client-specific information for users with patient/client role
- **Attributes**:
  - `date_of_birth` - Optional, may be required for certain service types
  - `health_goals` - Flexible text field (can be "goals", "objectives", "needs" depending on service type)
  - `medical_history_summary` - Optional encrypted field (only relevant for health/wellness services)
- **Associations**: `belongs_to :user`
- **Note**: For non-health services, health-related fields can remain empty or be repurposed

#### 4. Service
- **Purpose**: Specific offerings by providers (e.g., "60-Minute Strategy Consultation", "Tax Planning Session")
- **Attributes**:
  - `name` - Service name (e.g., "Executive Coaching Session", "Legal Document Review")
  - `description` - Detailed service description
  - `duration_minutes` - Session length
  - `price` - Service cost
  - `is_active` - Visibility toggle
- **Associations**:
  - `belongs_to :provider_profile`
  - `has_many :appointments`

#### 5. Availability
- **Purpose**: Time slots when providers are available for booking
- **Attributes**: start_time, end_time, is_booked (boolean flag)
- **Business Logic**: When appointment is created, corresponding availability is marked `is_booked: true`
- **Associations**: `belongs_to :provider_profile`

#### 6. Appointment (Central Transaction Model)
- **Purpose**: Scheduled session between client and service provider
- **Status Flow**:
  - `scheduled` → `completed` OR `cancelled_by_patient` OR `cancelled_by_provider` OR `no_show`
- **Attributes**:
  - patient_id (client), provider_id (service provider), service_id
  - start_time, end_time
  - status (enum)
  - cancellation_reason (optional text)
  - video_session_id (for video call integration - Zoom, Google Meet, custom solution)
- **Associations**:
  - `belongs_to :patient, class_name: 'User'` (the client)
  - `belongs_to :provider, class_name: 'User'` (the service provider)
  - `belongs_to :service`
  - `has_one :payment`
  - `has_one :consultation_note` (provider's private session notes)

#### 7. Payment
- **Purpose**: Stripe-integrated payment tracking for appointments/services
- **Status Flow**: `pending` → `succeeded` OR `failed`
- **Attributes**:
  - payer_id, appointment_id (optional - future: subscriptions, packages)
  - amount, currency (default: USD)
  - status (enum)
  - stripe_payment_intent_id (indexed for Stripe webhook lookups)
  - paid_at (timestamp)
- **Associations**:
  - `belongs_to :payer, class_name: 'User'`
  - `belongs_to :appointment, optional: true`

#### 8. ConsultationNote
- **Purpose**: Private session notes providers take during/after appointments
- **Attributes**: content (encrypted), appointment_id (unique - one note per appointment)
- **Security**: Only accessible to the provider who created it and admins
- **Use Cases**: Session summaries, action items, client progress tracking
- **Associations**: `belongs_to :appointment`

### Key Relationships

```
User (client role)
├─ has_one PatientProfile (client profile)
├─ has_many Appointments (as client)
└─ has_many Payments (as payer)

User (provider role)
├─ has_one ProviderProfile (professional profile)
│  ├─ has_many Services (service offerings)
│  └─ has_many Availabilities (schedule slots)
└─ has_many Appointments (as service provider)

Appointment (joins client + provider + service)
├─ has_one Payment
└─ has_one ConsultationNote (provider's notes)
```

## Core Business Logic

### 1. Provider Onboarding
- User signs up and sets role to `provider`
- ProviderProfile is created (mandatory before offering services)
- Provider must complete: specialty, credentials, bio
- Provider creates Services (offerings) and Availabilities (schedule)
- Provider can upload credentials/certifications (Active Storage)

### 2. Scheduling & Availability Management
- Providers create Availability records for open time slots
- Future enhancement: Recurring job to auto-generate weekly availability
- Client views: Query `Availability.where(is_booked: false, start_time: > Time.current)`
- Timezone handling: Convert all times to user's timezone (user.time_zone)

### 3. Booking Workflow
**Multi-step process:**
1. Client browses providers (filterable by specialty, price, availability)
2. Selects provider and views their services
3. Views available time slots
4. Selects service + time slot
5. Creates Appointment (status: `scheduled`)
6. Marks Availability as `is_booked: true`
7. Creates Payment (status: `pending`) with Stripe Payment Intent
8. Client completes payment
9. **Background job**: Release availability slot if payment not completed within 15 minutes

**Implementation notes:**
- Use Turbo Frames for smooth, SPA-like booking flow
- Prevent double-booking with database constraints and transactions
- Handle timezone conversions properly (user.time_zone)
- Send confirmation emails to both client and provider

### 4. Cancellation Logic
- Either client or provider can cancel
- Update appointment status to `cancelled_by_patient` or `cancelled_by_provider`
- Log `cancellation_reason`
- **Refund rules** (to be implemented):
  - >24 hours before: Full refund
  - <24 hours: Partial refund or no refund (configurable)
- Release availability slot back to unbooked
- Notify both parties via email

### 5. Video Session Integration (Future)
- Generate unique `video_session_id` before appointment starts
- Integration options:
  - Daily.co, Twilio Video (custom embedded solution)
  - Zoom, Google Meet (redirect to external platform)
  - WebRTC-based custom solution
- Both client and provider join via unique room URL
- Session recording options (with consent)

### 6. Authorization & Permissions (Pundit Policies)
**Provider permissions:**
- CRUD own ProviderProfile, Services, Availabilities
- View own appointments (as provider)
- Create/read ConsultationNotes for own appointments
- View client basic info (name, contact) but not sensitive profile data
- Cannot cancel appointments within 2 hours of start time (configurable)

**Client permissions:**
- CRUD own PatientProfile (client profile)
- Browse all active providers and services
- Book/cancel own appointments
- View own appointments and payment history
- Cannot view ConsultationNotes (provider's private notes)

**Admin permissions:**
- Read access to all data (support and moderation)
- User management capabilities
- Payment dispute resolution
- Platform analytics and reporting
- Service provider verification/approval

## Development Workflow

### Mandatory Git Workflow
**ALWAYS follow this workflow for every task:**

1. **Create a new branch** for each feature/fix:
   ```bash
   git checkout -b feature/feature-name
   # OR
   git checkout -b fix/bug-description
   ```

2. **Follow Test-Driven Development (TDD)**:
   - Write failing tests FIRST
   - Implement code to make tests pass
   - Refactor while keeping tests green
   - Red → Green → Refactor cycle

3. **Test before committing**:
   ```bash
   bin/rails test              # All tests must pass
   bin/rubocop                 # Linting must pass
   ```

4. **Commit with meaningful messages**:
   ```bash
   git add .
   git commit -m "feat: add provider availability management"
   # OR
   git commit -m "fix: prevent double-booking of appointment slots"
   ```

5. **Push and create PR**:
   ```bash
   git push -u origin feature/feature-name
   # Then create Pull Request via GitHub/GitLab
   ```

### Commit Message Convention
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `chore:` - Maintenance tasks

## Development Commands

### Initial Setup
```bash
bin/setup              # Install dependencies, prepare database, seed data
bin/setup --reset      # Full reset: drop, create, migrate, seed
```

### Database Management
```bash
bin/rails db:create           # Create database
bin/rails db:migrate          # Run pending migrations
bin/rails db:rollback         # Rollback last migration
bin/rails db:rollback STEP=3  # Rollback last 3 migrations
bin/rails db:reset            # Drop, create, migrate, and seed
bin/rails db:seed             # Run seed file
bin/rails db:prepare          # Create if needed, then migrate
```

### Running the Application
```bash
bin/dev                       # Start Rails server + Tailwind CSS watcher
bin/rails server              # Start Rails server only (port 3000)
bin/rails console             # Rails console (REPL)
```

### Testing (TDD Required)
```bash
# Run all tests
bin/rails test

# Run specific test types
bin/rails test:models
bin/rails test:controllers
bin/rails test:system

# Run specific test file
bin/rails test test/models/user_test.rb

# Run specific test by line number
bin/rails test test/models/user_test.rb:25

# Run with verbose output
bin/rails test -v

# Run tests in parallel (faster for large suites)
bin/rails test:parallel
```

### Code Quality & Security
```bash
bin/rubocop                  # Run RuboCop linter (Omakase Ruby style)
bin/rubocop -a              # Auto-correct safe offenses
bin/rubocop -A              # Auto-correct all offenses (use with caution)

bin/brakeman                # Static security vulnerability scanner
bin/brakeman -A             # Interactive mode to review findings

bundle-audit                # Check for vulnerable gem versions
bundle-audit update         # Update vulnerability database first
```

### Asset Management
```bash
bin/rails tailwindcss:watch    # Watch and rebuild Tailwind CSS (development)
bin/rails tailwindcss:build    # Build Tailwind CSS for production
```

### Debugging
```bash
bin/rails routes               # View all routes
bin/rails routes | grep user   # Search for specific routes
bin/rails db:schema:dump       # Update schema.rb from database
bin/rails notes                # Show TODO/FIXME comments
bin/rails stats                # Code statistics
```

## Testing Strategy

### Framework & Structure
- **Framework**: Minitest (Rails default)
- **Fixtures**: Use for test data in `test/fixtures/`
- **Coverage Goal**: Minimum 80% code coverage
- **Test Types**:
  - **Model tests**: Validations, associations, business logic, scopes
  - **Controller tests**: Authorization, request/response flow
  - **System tests**: End-to-end user workflows (Capybara + Selenium)

### Test Organization
```
test/
├── models/              # Unit tests for models
├── controllers/         # Controller action tests
├── system/             # End-to-end browser tests
├── integration/        # Cross-controller integration tests
├── helpers/            # View helper tests
├── mailers/            # Mailer tests
└── fixtures/           # Test data (YAML files)
```

### Writing Tests (TDD Approach)

**Example: Model Test**
```ruby
# test/models/appointment_test.rb
require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  test "should not save appointment without client" do
    appointment = Appointment.new(provider: users(:provider_one), service: services(:coaching))
    assert_not appointment.save, "Saved appointment without client"
  end

  test "should mark availability as booked when appointment created" do
    availability = availabilities(:monday_9am)
    assert_not availability.is_booked

    appointment = Appointment.create!(
      patient: users(:client_one),
      provider: users(:provider_one),
      service: services(:coaching),
      start_time: availability.start_time,
      end_time: availability.end_time
    )

    # Assume callback marks availability as booked
    availability.reload
    assert availability.is_booked, "Availability not marked as booked"
  end
end
```

**Example: System Test**
```ruby
# test/system/appointments_test.rb
require "application_system_test_case"

class AppointmentsTest < ApplicationSystemTestCase
  test "client can book an appointment" do
    sign_in users(:client_one)
    visit provider_profile_path(provider_profiles(:business_coach))

    click_on "Book Session"
    select "60-Minute Strategy Consultation", from: "Service"
    choose "Monday 9:00 AM"

    assert_difference "Appointment.count", 1 do
      click_button "Confirm Booking"
    end

    assert_text "Appointment successfully booked"
  end
end
```

## Key Architectural Decisions

### 1. Rails 8 Beta Choice
- **Why**: Access to Solid Stack (Queue, Cache, Cable) - eliminates Redis/Sidekiq dependencies
- **Trade-off**: Beta software may have bugs; stay updated with Rails changelog
- **Migration path**: Rails 8 GA expected soon; upgrade should be smooth

### 2. Role-Based Polymorphic Profiles
- **Why**: Clean separation of client vs provider data; single role per user
- **Alternative considered**: Multiple boolean role flags (rejected due to complexity)
- **Implementation**: User has ONE role enum, profiles created based on role
- **Flexibility**: PatientProfile fields can be repurposed for non-health services

### 3. Enum-Driven State Machines
- **Models with enums**: User (role), Appointment (status), Payment (status)
- **Why**: Type safety, clear state transitions, database-level constraints
- **Best practice**: Always use `default:` to avoid nil states

### 4. Availability Slot Booking Pattern
- **Pattern**: Pre-created availability slots with `is_booked` flag
- **Alternative considered**: Calculate availability on-the-fly (rejected: too complex)
- **Trade-off**: Requires providers to manually create slots or recurring job
- **Future**: Recurring availability generation (weekly schedules)

### 5. Hotwire-First Frontend
- **Why**: Minimal JavaScript, server-rendered HTML, progressive enhancement
- **Use cases**:
  - Turbo Frames: Booking form, provider profile updates
  - Turbo Streams: Real-time appointment updates, availability refresh
  - Stimulus: Interactive components (date pickers, form validations)
- **When to NOT use**: If you need heavy client-side state management, consider adding React

### 6. Pundit for Authorization
- **Why**: Explicit, testable policy objects; better than controller before_actions
- **Pattern**: One policy class per model (`AppointmentPolicy`, `ServicePolicy`)
- **Convention**: `authorize @record` in controller before any action

### 7. Stripe Payment Flow
- **Pattern**: Payment Intent → Confirm → Webhook for completion
- **Background job**: Timeout payment if not completed (release availability slot)
- **Refund logic**: Based on cancellation timing and platform policy
- **Future**: Support for subscriptions, packages, payment plans

### 8. Multi-Domain Service Support
- **Architecture**: Generic enough to support various professional services
- **Customization**: PatientProfile fields flexible (health_goals → client_goals)
- **Terminology**: Code uses "patient/provider", UI uses "client/service provider"
- **Future**: Service categories, provider verification by category

## Configuration & Environment

### Required Environment Variables
```bash
# Database
DATABASE_URL=postgresql://localhost/wellness_connect_development

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Video (future)
DAILY_API_KEY=...
# OR
ZOOM_CLIENT_ID=...
ZOOM_CLIENT_SECRET=...
# OR
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...

# Email (future - Action Mailer)
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_USERNAME=apikey
SMTP_PASSWORD=...
```

### Database Schema Management
- **Never edit `schema.rb` manually** - always use migrations
- **Make migrations reversible** - implement `down` method or use reversible methods
- **Test migrations**: `rails db:migrate && rails db:rollback && rails db:migrate`

## Common Development Tasks

### Adding a New Model
```bash
# 1. Generate model with attributes
rails g model ModelName attribute:type attribute:type

# 2. Edit migration if needed (add indexes, constraints)
# db/migrate/XXXXXX_create_model_names.rb

# 3. Run migration
bin/rails db:migrate

# 4. Add associations, validations, enums to model
# app/models/model_name.rb

# 5. Write tests FIRST
# test/models/model_name_test.rb

# 6. Add fixtures
# test/fixtures/model_names.yml
```

### Adding a New Feature (CRUD)
```bash
# 1. Create branch
git checkout -b feature/feature-name

# 2. Generate scaffold (or controller + views manually)
rails g scaffold ModelName attribute:type

# 3. Write tests FIRST (TDD)
# test/controllers/model_names_controller_test.rb

# 4. Add authorization policies
# app/policies/model_name_policy.rb

# 5. Implement controller actions with authorization
# app/controllers/model_names_controller.rb

# 6. Style views with Tailwind
# app/views/model_names/

# 7. Add routes
# config/routes.rb

# 8. Run tests
bin/rails test

# 9. Commit and PR
git add . && git commit -m "feat: add CRUD for ModelName"
git push -u origin feature/feature-name
```

## Troubleshooting

### Common Issues

**Database connection errors:**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql  # macOS
sudo service postgresql status        # Linux

# Recreate database
bin/rails db:drop db:create db:migrate db:seed
```

**Asset issues (Tailwind not updating):**
```bash
# Clear cache and precompile
bin/rails assets:clobber
bin/rails tailwindcss:build

# Or use dev server which auto-watches
bin/dev
```

**Test failures after migration:**
```bash
# Reset test database
RAILS_ENV=test bin/rails db:reset
```

**Devise routing issues:**
```bash
# Check Devise routes
bin/rails routes | grep devise
```

## Future Enhancements (Not in MVP)

### Platform Features
- **Service Categories**: Categorization system (Business, Legal, Health, Education, etc.)
- **Provider Verification**: Badge/verification system by service category
- **Advanced Search**: Filter by specialty, price, ratings, availability, location
- **Provider Reviews & Ratings**: Client feedback and rating system
- **Messaging**: Real-time chat between client and provider
- **Video Integration**: Embedded video (Daily.co, Twilio) or external (Zoom, Google Meet)

### Booking Enhancements
- **Recurring Appointments**: Weekly/monthly session packages
- **Group Sessions**: One provider, multiple clients
- **Waitlist**: Auto-booking when slots become available
- **Calendar Sync**: iCal/Google Calendar integration
- **Automated Reminders**: Email/SMS appointment reminders

### Payment Features
- **Subscription Plans**: Monthly retainers, session packages
- **Payment Plans**: Installment payments for expensive services
- **Multi-Currency**: International payment support
- **Invoicing**: Automated invoice generation
- **Refund Automation**: Policy-based automatic refunds

### Communication
- **Email Notifications**: Booking confirmations, reminders, cancellations
- **SMS Notifications**: Twilio integration for time-sensitive alerts
- **In-App Notifications**: Real-time notification system
- **Automated Follow-Ups**: Post-session feedback requests

### Admin & Analytics
- **Admin Dashboard**: User management, service provider approval, moderation
- **Analytics Dashboard**: Booking trends, revenue metrics, provider performance
- **Dispute Resolution**: Payment dispute management system
- **Reporting Tools**: Financial reports, user activity reports

## Additional Resources

- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Hotwire Documentation](https://hotwired.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Stripe Ruby SDK](https://stripe.com/docs/api?lang=ruby)
- [Pundit Documentation](https://github.com/varvet/pundit)
- [Devise Documentation](https://github.com/heartcombo/devise)
