# Copilot Instructions for WellnessConnect

## Architecture Overview

WellnessConnect is a **Rails 8.1** healthcare marketplace connecting patients with wellness providers. The app uses a dual-role user model where a single `User` can have both `patient_profile` and `provider_profile` relationships.

### Core Domain Model
- **Users** have roles: `patient`, `provider`, `admin`, `super_admin` (enum in `app/models/user.rb`)
- **Provider ↔ Patient** relationships are modeled through `Appointment`, `Conversation`, and `Payment` with explicit `patient_id`/`provider_id` foreign keys
- **Appointments** link to `Service`, `Availability`, and optional `Payment`/`ConsultationNote`
- Conversations track `patient_unread_count`/`provider_unread_count` separately

### Tech Stack
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS, Importmap (no Node.js build)
- **Background Jobs**: Solid Queue (`config/recurring.yml` for scheduled jobs)
- **Caching/Cable**: Solid Cache, Solid Cable (database-backed)
- **Auth**: Devise | **Authorization**: Pundit policies in `app/policies/`
- **Payments**: Stripe (`StripeWebhooksController` for webhooks)
- **Deploy**: Fly.io with `fly.toml`, Kamal support via `config/deploy.yml`

## Key Patterns

### Authorization with Pundit
Every controller action must call `authorize` with the resource:
```ruby
def show
  @appointment = Appointment.find(params[:id])
  authorize @appointment  # Uses AppointmentPolicy#show?
end
```
Policies scope records per user role. See `ConversationPolicy` for dual-participant authorization pattern.

### Notification System
Use `NotificationService` (not direct `Notification.create!`) to respect user preferences:
```ruby
NotificationService.notify_appointment_booked(appointment)  # Checks preferences, sends email + in-app
```
Notification preferences are per-user in `notification_preferences` table with `email_*` and `in_app_*` boolean columns.

### Stimulus Controllers
Controllers live in `app/javascript/controllers/`. Common patterns:
- `dropdown_controller.js` - Reusable dropdown menus
- `toast_controller.js` - Flash message auto-dismiss
- `booking_form_controller.js` - Multi-step appointment booking

### Shared View Components
Reusable partials in `app/views/shared/`:
- `_user_avatar.html.erb` - Use via `AvatarHelper#render_user_avatar(user, size: :medium)`
- `_toast.html.erb` - Flash messages with Turbo Stream support
- `_navbar.html.erb`, `_footer.html.erb` - Layout components

### User Status Management
Users have `suspended_at` and `blocked_at` timestamps. Use instance methods:
```ruby
user.suspend!(reason)  # Sets suspended_at
user.active?           # Checks both suspended_at and blocked_at are nil
```

## Development Commands

```bash
bin/dev              # Start Rails server + Tailwind watcher (Procfile.dev)
bin/rails test       # Run Minitest suite (uses mocha for mocking)
bin/rails test:system # System tests with Capybara
bin/rubocop          # Lint with Rails Omakase style
bin/brakeman         # Security static analysis
bin/bundler-audit    # Gem vulnerability check
```

## Testing Patterns
- Fixtures in `test/fixtures/` - load with `fixtures :all` in test_helper
- Devise helpers: `sign_in users(:patient)` in integration tests
- Policy tests in `test/policies/` - test each action method

## Database Conventions
- Counter caches: `appointments_count`, `services_count`, `availabilities_count`
- Check constraints enforce business rules (e.g., `end_time > start_time`, `rating BETWEEN 1 AND 5`)
- Composite indexes optimize common queries - see `schema.rb` comments

## Security Considerations
- `Rack::Attack` configured in `config/initializers/rack_attack.rb` (rate limiting on auth endpoints)
- `SecurityLogger` concern logs auth/security events
- CSRF: `per_form_csrf_tokens = true` in ApplicationController
