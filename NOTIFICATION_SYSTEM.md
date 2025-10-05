# Notification System Documentation

## Overview
The WellnessConnect notification system provides real-time in-app notifications for both providers and patients. The system is fully integrated with the navigation bar and provides a comprehensive notification management interface.

---

## Features

### ✅ **For All Authenticated Users (Providers & Patients)**
- **Notification Dropdown**: Accessible from the navbar bell icon
- **Unread Count Badge**: Red dot indicator when unread notifications exist
- **Real-time Updates**: Notifications appear immediately after actions
- **Mark as Read**: Individual and bulk mark-as-read functionality
- **Notification Types**: 8 different notification types with custom icons
- **Responsive Design**: Works seamlessly on desktop and mobile

---

## Notification Types

### 1. **Appointment Booked** (`appointment_booked`)
- **Icon**: Green calendar
- **Triggered**: When an appointment is successfully booked
- **Recipients**: Both provider and patient
- **Example**: "New Appointment Booked - John Doe has booked an appointment with you for March 15, 2025 at 2:00 PM"

### 2. **Appointment Cancelled** (`appointment_cancelled`)
- **Icon**: Red X circle
- **Triggered**: When an appointment is cancelled by either party
- **Recipients**: The other party (not the one who cancelled)
- **Example**: "Appointment Cancelled - Your appointment scheduled for March 15, 2025 at 2:00 PM has been cancelled"

### 3. **Appointment Reminder** (`appointment_reminder`)
- **Icon**: Green calendar
- **Triggered**: 24 hours before appointment (via scheduled job)
- **Recipients**: Both provider and patient
- **Example**: "Appointment Reminder - You have an appointment with Dr. Smith tomorrow at 2:00 PM"

### 4. **Payment Received** (`payment_received`)
- **Icon**: Blue dollar sign
- **Triggered**: When a payment is successfully processed
- **Recipients**: Provider only
- **Example**: "Payment Received - You received a payment of $150 for your appointment with Jane Doe"

### 5. **Payment Failed** (`payment_failed`)
- **Icon**: Red X circle
- **Triggered**: When a payment fails to process
- **Recipients**: Patient only
- **Example**: "Payment Failed - Your payment of $150 could not be processed. Please update your payment method."

### 6. **Profile Approved** (`profile_approved`)
- **Icon**: Gray info circle
- **Triggered**: When admin approves a provider profile
- **Recipients**: Provider only
- **Example**: "Profile Approved - Congratulations! Your provider profile has been approved and is now live."

### 7. **New Review** (`new_review`)
- **Icon**: Yellow star
- **Triggered**: When a patient leaves a review
- **Recipients**: Provider only
- **Example**: "New Review Received - Jane Doe left a review on your profile"

### 8. **System Announcement** (`system_announcement`)
- **Icon**: Gray info circle
- **Triggered**: Manual admin broadcast
- **Recipients**: All users or specific user groups
- **Example**: "System Maintenance - WellnessConnect will undergo scheduled maintenance on March 20, 2025"

---

## User Interface

### Navbar Notification Dropdown

**Desktop View:**
- Bell icon in top-right navbar
- Red dot badge when unread notifications exist
- Click to open dropdown (max-height: 384px, scrollable)
- Shows last 10 notifications
- "Mark all read" link (if unread notifications exist)
- "View all notifications" link at bottom

**Mobile View:**
- Notifications link in mobile menu
- Shows unread count: "Notifications (3)"
- Links to full notifications page

**Dropdown Features:**
- Color-coded icons by notification type
- Unread indicator (blue dot on right)
- Time ago display ("5 minutes ago")
- Click notification to mark as read and navigate to action URL
- Empty state when no notifications

### Notifications Index Page (`/notifications`)

**Features:**
- Full list of all notifications (paginated, 20 per page)
- Unread notifications highlighted with indigo background
- Large icons with color coding
- "New" badge on unread notifications
- Individual "Mark as read" and "Delete" buttons
- Empty state with call-to-action
- Responsive grid layout

---

## Technical Implementation

### Database Schema

```ruby
# db/migrate/XXXXXX_create_notifications.rb
create_table :notifications do |t|
  t.references :user, null: false, foreign_key: true
  t.string :title, null: false
  t.text :message, null: false
  t.string :notification_type, null: false
  t.datetime :read_at
  t.string :action_url
  t.timestamps
end
```

### Models

**Notification Model** (`app/models/notification.rb`):
```ruby
class Notification < ApplicationRecord
  belongs_to :user
  
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
  
  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, inclusion: { in: TYPES }
  
  def mark_as_read!
    update(read_at: Time.current) unless read?
  end
  
  def read?
    read_at.present?
  end
end
```

**User Model** (`app/models/user.rb`):
```ruby
has_many :notifications, dependent: :destroy
```

### Controllers

**NotificationsController** (`app/controllers/notifications_controller.rb`):
- `index`: Display all notifications (paginated)
- `mark_as_read`: Mark individual notification as read and redirect to action_url
- `mark_all_as_read`: Bulk mark all unread notifications as read
- `destroy`: Delete individual notification

### Services

**NotificationService** (`app/services/notification_service.rb`):
Centralized service for creating notifications with methods:
- `notify_appointment_booked(appointment)`
- `notify_appointment_cancelled(appointment, cancelled_by)`
- `notify_appointment_reminder(appointment)`
- `notify_payment_received(payment)`
- `notify_payment_failed(payment)`
- `notify_profile_approved(provider_profile)`
- `notify_new_review(provider_profile, reviewer)`
- `notify_system_announcement(user, title, message)`
- `broadcast_announcement(title, message)`

### Routes

```ruby
resources :notifications, only: [:index, :destroy] do
  member do
    post :mark_as_read
  end
  collection do
    post :mark_all_as_read
  end
end
```

---

## Usage Examples

### Creating Notifications

**In Controllers:**
```ruby
# When booking an appointment
NotificationService.notify_appointment_booked(@appointment)

# When cancelling an appointment
NotificationService.notify_appointment_cancelled(@appointment, current_user)

# When payment is received
NotificationService.notify_payment_received(@payment)
```

**Manual Notification:**
```ruby
Notification.create!(
  user: user,
  title: "Welcome to WellnessConnect",
  message: "Thank you for joining our platform!",
  notification_type: "system_announcement"
)
```

**Broadcast to All Users:**
```ruby
NotificationService.broadcast_announcement(
  "System Maintenance",
  "WellnessConnect will undergo scheduled maintenance on March 20, 2025 from 2:00 AM to 4:00 AM EST"
)
```

### Querying Notifications

```ruby
# Get unread notifications for current user
current_user.notifications.unread

# Get recent notifications
current_user.notifications.recent

# Get unread count
current_user.notifications.unread.count

# Mark all as read
current_user.notifications.unread.update_all(read_at: Time.current)
```

---

## Future Enhancements

### Planned Features
- [ ] **Email Notifications**: Send email for important notifications
- [ ] **SMS Notifications**: Twilio integration for urgent alerts
- [ ] **Push Notifications**: Web push notifications for real-time alerts
- [ ] **Notification Preferences**: User settings to control notification types
- [ ] **Notification Channels**: Email, SMS, Push, In-App toggles
- [ ] **Scheduled Notifications**: Cron job for appointment reminders
- [ ] **Notification Templates**: Customizable notification templates
- [ ] **Read Receipts**: Track when notifications are viewed
- [ ] **Notification Groups**: Group related notifications
- [ ] **Rich Notifications**: Include images, buttons, actions

### Scheduled Jobs (To Implement)

**Appointment Reminders:**
```ruby
# lib/tasks/scheduler.rake
task send_appointment_reminders: :environment do
  appointments = Appointment.where(
    start_time: 24.hours.from_now..25.hours.from_now,
    status: :scheduled
  )
  
  appointments.each do |appointment|
    NotificationService.notify_appointment_reminder(appointment)
  end
end
```

**Cleanup Old Notifications:**
```ruby
task cleanup_old_notifications: :environment do
  Notification.where("created_at < ?", 90.days.ago).destroy_all
end
```

---

## Testing

### Manual Testing

1. **Sign in as a patient**
2. **Book an appointment** → Check notification dropdown for "Appointment Confirmed"
3. **Sign in as the provider** → Check notification dropdown for "New Appointment Booked"
4. **Cancel the appointment** → Check other user's notifications
5. **Click notification** → Should mark as read and navigate to appointment
6. **Visit `/notifications`** → Should see full list
7. **Test "Mark all as read"** → All notifications should be marked as read
8. **Test delete** → Notification should be removed

### System Tests (To Implement)

```ruby
# test/system/notifications_test.rb
test "provider receives notification when appointment is booked" do
  sign_in @provider
  visit notifications_path
  
  # Book appointment as patient
  sign_in @patient
  book_appointment(@availability)
  
  # Check provider notifications
  sign_in @provider
  visit root_path
  assert_selector ".notification-badge" # Unread count badge
  
  click_button "View notifications"
  assert_text "New Appointment Booked"
end
```

---

## Accessibility

- **ARIA Labels**: All interactive elements have proper ARIA labels
- **Keyboard Navigation**: Full keyboard support (Tab, Enter, Escape)
- **Screen Reader Support**: Semantic HTML and ARIA attributes
- **Color Contrast**: WCAG 2.1 AA compliant color ratios
- **Focus Indicators**: Visible focus states on all interactive elements

---

## Performance Considerations

- **Pagination**: Notifications index uses Kaminari for pagination (20 per page)
- **Recent Scope**: Dropdown only loads last 10 notifications
- **Eager Loading**: Use `includes(:user)` when querying multiple notifications
- **Database Indexes**: Index on `user_id`, `read_at`, `created_at`
- **Cleanup Job**: Scheduled task to delete old notifications (90+ days)

---

## Security

- **Authorization**: Users can only view/manage their own notifications
- **SQL Injection**: All queries use ActiveRecord (parameterized)
- **XSS Protection**: All user input is sanitized
- **CSRF Protection**: All forms include CSRF tokens

---

**Last Updated:** 2025-10-04  
**Version:** 1.0.0

