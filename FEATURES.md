# WellnessConnect - Feature Documentation

> **Complete guide to all implemented features**: Authentication, navigation, notifications, provider profiles, super admin, appointment reminders, and search.

---

## 📋 Table of Contents

### Core Features
- [Authentication System](#authentication-system)
- [Navigation System](#navigation-system)
- [Notification System](#notification-system)
- [Provider Profile System](#provider-profile-system)

### Admin Features
- [Super Admin Implementation](#super-admin-implementation)

### Automation Features
- [Appointment Reminders](#appointment-reminders)

### Search & Discovery
- [Search Bar System](#search-bar-system)

---

## Authentication System

### Overview
Premium, accessible authentication pages implemented with modern UX design principles focusing on accessibility, usability, and visual appeal.

### Implemented Pages

#### 1. Sign-In Page (`/users/sign_in`)
**File:** `app/views/devise/sessions/new.html.erb`

**Features:**
- Split-screen layout (desktop) with branding on left, form on right
- Email and password fields with icon indicators
- Password visibility toggle for better UX
- Remember me checkbox for persistent sessions
- Forgot password link for easy password recovery
- Create account link for new users
- Responsive design that adapts to mobile, tablet, and desktop
- High-contrast colors for readability
- Large tap targets (44px minimum) for accessibility
- ARIA labels for screen reader compatibility

**Visual Design:**
- Gradient background (indigo to purple)
- White card with rounded corners (rounded-3xl)
- Shadow effects for depth
- Smooth transitions and hover effects
- Brand logo and benefits list on left panel

#### 2. Sign-Up Page (`/users/sign_up`)
**File:** `app/views/devise/registrations/new.html.erb`

**Features:**
- Split-screen layout with benefits on left, form on right
- First name and last name fields for personalization
- Email field with validation
- Password field with strength indicator
- Password confirmation field with visibility toggle
- Real-time password strength indicator (Weak/Fair/Good/Strong)
- Role selection (Client/Provider) with visual radio buttons
- Terms and conditions checkbox (required)
- Responsive grid layout for name fields
- Clear error messaging with styled error container
- Sign in link for existing users

**Visual Design:**
- Purple to pink gradient background
- Interactive role selection cards
- Color-coded password strength bar
- Accessible form inputs with clear labels
- Social proof elements (user count)

#### 3. Password Reset Page (`/users/password/new`)
**File:** `app/views/devise/passwords/new.html.erb`

**Features:**
- Centered card layout for focused experience
- Email field for password reset
- Clear instructions and helpful messaging
- Back to sign in link for easy navigation
- Support contact information for assistance
- Icon-based visual hierarchy

### Technical Implementation

#### Stimulus Controller
**File:** `app/javascript/controllers/password_controller.js`

Provides interactive functionality for:
- **Password visibility toggle** - Shows/hides password text
- **Password strength calculation** - Real-time strength assessment
- **Visual feedback** - Updates strength bar and text dynamically

**Strength Calculation:**
- Length >= 8 characters: +25 points
- Length >= 12 characters: +25 points
- Mixed case (a-z, A-Z): +25 points
- Contains numbers: +15 points
- Contains special characters: +10 points
- Maximum: 100 points

**Strength Levels:**
- 0-39: Weak (red)
- 40-69: Fair (yellow)
- 70-89: Good (blue)
- 90-100: Strong (green)

#### Parameter Sanitization
**File:** `app/controllers/application_controller.rb`

Configured to permit additional user parameters:
- `first_name`
- `last_name`
- `role` (patient/provider)

### Accessibility Features

#### WCAG 2.1 AA Compliance:
1. **Color Contrast**: All text meets 4.5:1 contrast ratio
2. **Keyboard Navigation**: All interactive elements are keyboard accessible
3. **Screen Reader Support**: ARIA labels on all form inputs
4. **Focus Indicators**: Clear focus states on all interactive elements
5. **Error Identification**: Clear error messages with visual and text indicators
6. **Large Touch Targets**: Minimum 44x44px for all buttons and links

#### Inclusive UX Design:
1. **Plain Language**: Clear, jargon-free labels and instructions
2. **Visual Hierarchy**: Logical flow from top to bottom
3. **Progressive Disclosure**: Password strength shown only when typing
4. **Contextual Help**: Tooltips and helper text where needed
5. **Error Prevention**: Client-side validation before submission
6. **Consistent Layout**: Similar structure across all auth pages

### Responsive Design

**Breakpoints:**
- **Mobile** (< 640px): Single column, stacked layout
- **Tablet** (640px - 1024px): Optimized spacing and sizing
- **Desktop** (> 1024px): Split-screen layout with branding panel

**Mobile Optimizations:**
- Logo shown at top on mobile
- Benefits panel hidden on mobile
- Full-width form inputs
- Larger touch targets
- Optimized font sizes

### Color Scheme

**Primary Colors:**
- **Indigo-600**: `#4F46E5` - Primary brand color
- **Purple-600**: `#9333EA` - Secondary brand color
- **White**: `#FFFFFF` - Background and text

**Accent Colors:**
- **Green**: Success states and strong passwords
- **Yellow**: Warning states and fair passwords
- **Red**: Error states and weak passwords
- **Blue**: Info states and good passwords

**Gradients:**
- Sign-in: `from-indigo-600 to-purple-600`
- Sign-up: `from-purple-600 to-pink-600`
- Buttons: `from-indigo-600 to-purple-600`

---

## Navigation System

### Overview
Comprehensive navigation system with responsive navbar and footer components for seamless site navigation.

### Components

#### 1. Navigation Bar (`app/views/shared/_navbar.html.erb`)
A fixed-top, responsive navigation bar with advanced features.

#### 2. Footer (`app/views/shared/_footer.html.erb`)
A comprehensive footer with links, social media, and trust badges.

#### 3. Stimulus Controllers
- `navbar_controller.js` - Mobile menu functionality
- `dropdown_controller.js` - Dropdown menu interactions

### Navbar Features

#### Desktop Navigation
- **Logo & Branding**: Gradient text logo with icon
- **Main Navigation Links**: Home, Services, Providers, About
- **Dropdown Menus**: Services and About sections with icons
- **Notifications**: Bell icon with badge and dropdown panel
- **User Profile**: Avatar with dropdown menu
- **Authentication**: Sign In and Get Started buttons (when logged out)

#### Mobile Navigation
- **Hamburger Menu**: Toggles mobile menu
- **Responsive Layout**: Optimized for all screen sizes
- **Touch-Friendly**: Large tap targets for mobile devices

#### Notification System
Features:
- Bell icon with red badge indicator
- Dropdown panel with notification items
- Icons for different notification types
- Timestamps for each notification
- "View all notifications" link
- Scrollable list (max-height with overflow)

#### User Profile Dropdown
Features:
- User avatar with initials
- Full name and email display
- Role badge (Client/Provider/Admin)
- Quick links:
  - My Profile
  - My Appointments
  - Billing
  - Settings
- Sign Out button (red styling)

### Footer Features

#### Four-Column Layout
1. **Company Info**
   - Logo and branding
   - Company description
   - Social media links (Facebook, Twitter, LinkedIn, Instagram)

2. **Quick Links**
   - Home
   - Browse Services
   - Find Providers
   - Book Appointment
   - How It Works

3. **Support**
   - Help Center
   - Contact Us
   - FAQs
   - Safety & Privacy
   - Accessibility

4. **Legal**
   - Terms of Service
   - Privacy Policy
   - Cookie Policy
   - HIPAA Compliance
   - Provider Agreement

#### Bottom Bar
- Copyright notice with dynamic year
- Trust badges (HIPAA Compliant, SSL Secured)
- Responsive layout

### Accessibility Features

**ARIA Attributes:**
- `aria-label` on icon-only buttons
- `aria-expanded` on dropdown toggles
- `aria-haspopup` on menu buttons
- `role="alert"` on flash messages

**Keyboard Navigation:**
- All interactive elements are keyboard accessible
- Tab order follows logical flow
- Dropdowns can be closed with Escape key (future enhancement)

**Screen Reader Support:**
- Semantic HTML elements
- Descriptive link text
- Icon buttons have labels
- Status messages announced

**Visual Accessibility:**
- High contrast ratios (WCAG AA compliant)
- Focus indicators on interactive elements
- Sufficient touch target sizes (44x44px minimum)
- Readable font sizes

### Responsive Behavior

**Mobile (< 768px):**
- Hamburger menu for main navigation
- Stacked layout
- Full-width buttons
- Simplified user menu
- Hidden desktop elements

**Tablet (768px - 1024px):**
- Partial desktop navigation
- Some elements hidden
- Optimized spacing
- Touch-friendly targets

**Desktop (> 1024px):**
- Full navigation visible
- Dropdown menus
- Hover states
- Optimal spacing

---

## Notification System

### Overview
Real-time in-app notification system for both providers and patients, fully integrated with the navigation bar.

### Features

**For All Authenticated Users (Providers & Patients):**
- Notification Dropdown: Accessible from the navbar bell icon
- Unread Count Badge: Red dot indicator when unread notifications exist
- Real-time Updates: Notifications appear immediately after actions
- Mark as Read: Individual and bulk mark-as-read functionality
- Notification Types: 8 different notification types with custom icons
- Responsive Design: Works seamlessly on desktop and mobile

### Notification Types

#### 1. Appointment Booked (`appointment_booked`)
- **Icon**: Green calendar
- **Triggered**: When an appointment is successfully booked
- **Recipients**: Both provider and patient
- **Example**: "New Appointment Booked - John Doe has booked an appointment with you for March 15, 2025 at 2:00 PM"

#### 2. Appointment Cancelled (`appointment_cancelled`)
- **Icon**: Red X circle
- **Triggered**: When an appointment is cancelled by either party
- **Recipients**: The other party (not the one who cancelled)
- **Example**: "Appointment Cancelled - Your appointment scheduled for March 15, 2025 at 2:00 PM has been cancelled"

#### 3. Appointment Reminder (`appointment_reminder`)
- **Icon**: Green calendar
- **Triggered**: 24 hours before appointment (via scheduled job)
- **Recipients**: Both provider and patient
- **Example**: "Appointment Reminder - You have an appointment with Dr. Smith tomorrow at 2:00 PM"

#### 4. Payment Received (`payment_received`)
- **Icon**: Blue dollar sign
- **Triggered**: When a payment is successfully processed
- **Recipients**: Provider only
- **Example**: "Payment Received - You received a payment of $150 for your appointment with Jane Doe"

#### 5. Payment Failed (`payment_failed`)
- **Icon**: Red X circle
- **Triggered**: When a payment fails to process
- **Recipients**: Patient only
- **Example**: "Payment Failed - Your payment of $150 could not be processed. Please update your payment method."

#### 6. Profile Approved (`profile_approved`)
- **Icon**: Gray info circle
- **Triggered**: When admin approves a provider profile
- **Recipients**: Provider only
- **Example**: "Profile Approved - Congratulations! Your provider profile has been approved and is now live."

#### 7. New Review (`new_review`)
- **Icon**: Yellow star
- **Triggered**: When a patient leaves a review
- **Recipients**: Provider only
- **Example**: "New Review Received - Jane Doe left a review on your profile"

#### 8. System Announcement (`system_announcement`)
- **Icon**: Gray info circle
- **Triggered**: Manual admin broadcast
- **Recipients**: All users or specific user groups
- **Example**: "System Maintenance - WellnessConnect will undergo scheduled maintenance on March 20, 2025"

### User Interface

#### Navbar Notification Dropdown

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

#### Notifications Index Page (`/notifications`)

**Features:**
- Full list of all notifications (paginated, 20 per page)
- Unread notifications highlighted with indigo background
- Large icons with color coding
- "New" badge on unread notifications
- Individual "Mark as read" and "Delete" buttons
- Empty state with call-to-action
- Responsive grid layout

### Technical Implementation

#### Database Schema
```ruby
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

#### Models

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

#### Controllers

**NotificationsController** (`app/controllers/notifications_controller.rb`):
- `index`: Display all notifications (paginated)
- `mark_as_read`: Mark individual notification as read and redirect to action_url
- `mark_all_as_read`: Bulk mark all unread notifications as read
- `destroy`: Delete individual notification

#### Services

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

#### Routes
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

## Provider Profile System

### Overview
Comprehensive, modern, and sophisticated profile page implementation designed to showcase healthcare providers professionally.

### Features

#### 1. Hero/Header Section
- Premium Design: Gradient background (indigo to purple) with decorative elements
- Provider Avatar: Large circular profile photo with verification badge
- Provider Information: Name, credentials, specialty, and years of experience
- Rating Display: 5-star rating system with review count
- Quick Action Buttons: Book Appointment, Message, and Share functionality
- Responsive Layout: Adapts beautifully from mobile to desktop

#### 2. About Section
- Professional Bio: Rich text biography with proper formatting
- Experience Highlights: Years of experience displayed prominently
- Education: Detailed educational background
- Certifications: Professional certifications and credentials
- Languages: Multi-language support with visual tags
- Visual Design: Icon-based information cards with color-coded sections

#### 3. Media Gallery
**Multi-Format Support:**
- Images (JPEG, PNG, WebP) - up to 10MB each
- Videos (MP4, MOV, AVI) - up to 100MB each
- Audio (MP3, WAV, OGG) - up to 50MB each
- PDFs (certifications, articles) - up to 20MB each

**Features:**
- Interactive Lightbox: Full-screen media viewer with navigation
- Keyboard Navigation: Arrow keys for next/previous, Escape to close
- Responsive Grid: 2-4 columns depending on screen size
- Visual Indicators: Color-coded badges for media types

#### 4. Services Section
- Service Cards: Modern card design with gradient backgrounds
- Pricing Display: Clear pricing with session duration
- Service Details: Name, description, duration, and price
- Booking Integration: Direct links to booking system
- Active/Inactive Status: Only shows active services
- Empty State: Friendly message when no services available

#### 5. Availability & Booking
- Sidebar Widget: Sticky booking widget with consultation rate
- Next Available Slots: Shows upcoming 5 available time slots
- Quick Booking: One-click booking for authenticated patients
- Call-to-Action: Clear CTAs for booking appointments
- Empty State: Informative message when no slots available

#### 6. Reviews & Testimonials
- Rating Summary: Large rating display with breakdown by stars
- Testimonial Carousel: Rotating client testimonials
- Verified Reviews: Visual indicators for verified reviews
- Rating Distribution: Visual bar chart showing rating breakdown
- Write Review CTA: Encourages patients to leave reviews
- Carousel Controls: Previous/Next buttons and indicators

#### 7. Contact & Location
- Contact Information: Phone, email, office address
- Website Link: External link to provider's website
- Social Media Integration: LinkedIn, Twitter, Facebook, Instagram
- Visual Icons: Platform-specific icons and colors
- Clickable Links: Direct links to contact methods

#### 8. Quick Stats Widget
- Key Metrics: Reviews, experience, services, response time
- Visual Design: Gradient background with icon-based stats
- Trust Badges: Verified and Secure badges
- Sticky Positioning: Stays visible while scrolling

### Technical Implementation

#### Database Schema
```ruby
# provider_profiles table
- specialty: string
- bio: text
- credentials: text
- consultation_rate: decimal
- years_of_experience: integer
- education: text
- certifications: text
- languages: text
- phone: string
- office_address: text
- website: string
- linkedin_url: string
- twitter_url: string
- facebook_url: string
- instagram_url: string
- average_rating: decimal
- total_reviews: integer
```

#### Active Storage Attachments
```ruby
# ProviderProfile model
has_one_attached :avatar
has_many_attached :gallery_images
has_many_attached :gallery_videos
has_many_attached :gallery_audio
has_many_attached :documents
```

#### File Validations
- Avatar: JPEG/PNG/WebP, max 5MB
- Gallery Images: JPEG/PNG/WebP, max 10MB each
- Gallery Videos: MP4/MOV/AVI, max 100MB each
- Gallery Audio: MP3/WAV/OGG, max 50MB each
- Documents: PDF only, max 20MB each

#### Stimulus Controllers

**1. Media Gallery Controller (`media_gallery_controller.js`)**
- Opens lightbox with selected media
- Navigates between media items
- Handles keyboard shortcuts
- Supports all media types (image, video, audio, PDF)
- Click-outside-to-close functionality

**2. Smooth Scroll Controller (`smooth_scroll_controller.js`)**
- Smooth scrolling to section anchors
- Accounts for fixed navbar offset
- Enhances navigation experience

**3. Carousel Controller (`carousel_controller.js`)**
- Testimonial carousel functionality
- Auto-play support (optional)
- Manual navigation (previous/next)
- Indicator dots for slide position
- Keyboard accessible

### Accessibility Features

**WCAG 2.1 AA Compliance:**
- Proper heading hierarchy (h1, h2, h3)
- ARIA labels for interactive elements
- Keyboard navigation support
- Alt text for images
- High contrast ratios (4.5:1 minimum)
- Focus indicators on interactive elements
- Screen reader compatible
- Semantic HTML structure

**Keyboard Navigation:**
- Tab: Navigate through interactive elements
- Enter/Space: Activate buttons and links
- Arrow Keys: Navigate media gallery (when lightbox open)
- Escape: Close lightbox/modals

### Responsive Design

**Breakpoints:**
- Mobile: < 768px (1 column layout)
- Tablet: 768px - 1024px (2 column layout)
- Desktop: > 1024px (3 column layout with sidebar)

**Mobile Optimizations:**
- Hamburger menu for navigation tabs
- Stacked layout for hero section
- Touch-friendly button sizes (minimum 44x44px)
- Optimized image loading
- Reduced motion for animations

---

## Super Admin Implementation

### Overview
Role-based user creation functionality where super admins can create both provider and patient accounts through the admin interface.

### Implementation Date
October 5, 2025

### Branch
`feature/super-admin-user-creation`

### Requirements Implemented

#### 1. Authorization ✅
- **Super Admin Role**: Added new `super_admin` role (enum value: 3) to the User model
- **Access Control**: Only users with the `super_admin` role can create, edit, delete, suspend, and block users
- **Regular Admin**: Regular admins (role: 2) can view users and access the admin interface but cannot manage users
- **Policy-Based**: Implemented using Pundit policies for clean, maintainable authorization

#### 2. Admin User Form ✅
- **Role Selection**: Updated form to include all roles (patient, provider, admin, super_admin)
- **Dynamic Fields**: Role-specific information sections that show/hide based on selected role
- **Accessibility**: WCAG 2.1 AA compliant with clear labels, helper text, and visual indicators
- **User Experience**: Informative messages for each role explaining what will be created

#### 3. Controller Logic ✅
- **Authorization Check**: Verifies current user has super_admin privileges before allowing user creation
- **Profile Creation**: Automatically creates provider or patient profiles when users with those roles are created
- **Role Changes**: Handles profile creation when user roles are changed
- **Error Handling**: Graceful error handling with logging for profile creation failures

#### 4. Routes ✅
- **Existing Routes**: Leveraged existing admin routes for user management
- **No Changes Needed**: All necessary routes were already in place

#### 5. Testing ✅
- **TDD Approach**: Wrote tests first, then implemented functionality
- **Comprehensive Coverage**: 47 tests covering all authorization scenarios
- **Test Results**: 45 passing tests, 2 view-related failures (unrelated to authorization)
- **Test Coverage**:
  - Super admins can create provider accounts ✅
  - Super admins can create patient accounts ✅
  - Super admins can create admin accounts ✅
  - Super admins can create other super_admin accounts ✅
  - Regular admins cannot create users ✅
  - Non-admin users cannot access functionality ✅
  - Proper validations are enforced ✅

#### 6. UI/UX ✅
- **Accessible Design**: Form follows WCAG 2.1 AA standards
- **Clear Labels**: All form fields have descriptive labels with required field indicators
- **Helper Text**: Contextual help text for each role explaining permissions
- **Visual Feedback**: Color-coded information boxes for different role types
- **Responsive**: Works on all screen sizes with proper touch targets (44px+)

### Technical Implementation Details

#### Database Changes
**Migration**: `20251005225938_add_super_admin_role_to_users.rb`
```ruby
# No database schema changes required
# The super_admin role is added to the User model enum
# Existing roles: patient (0), provider (1), admin (2)
# New role: super_admin (3)
```

#### Model Changes
**`app/models/user.rb`**:
```ruby
# Updated enum to include super_admin role
enum :role, {
  patient: 0,
  provider: 1,
  admin: 2,
  super_admin: 3
}, default: :patient
```

#### Policy Changes

**`app/policies/admin_policy.rb`**:
- Added `super_admin_user?` helper method
- Updated `admin_user?` to allow both admin and super_admin access to admin namespace

**`app/policies/admin/user_policy.rb`**:
- `index?` and `show?`: Both admin and super_admin can view users
- `new?` and `create?`: Only super_admin can create users
- `edit?` and `update?`: Only super_admin can edit users
- `destroy?`: Only super_admin can delete users (and cannot delete themselves)
- `suspend?`, `unsuspend?`, `block?`, `unblock?`: Only super_admin can manage user status

#### Controller Changes

**`app/controllers/admin/base_controller.rb`**:
- Updated `require_admin!` to allow both admin and super_admin access

**`app/controllers/admin/users_controller.rb`**:
- Updated all `authorize` calls to use `[:admin, @user]` format for proper policy resolution
- Added `create_role_profile` method to automatically create provider/patient profiles
- Enhanced `create` action to create profiles after user creation
- Enhanced `update` action to create profiles when role changes

#### View Changes

**`app/views/admin/users/_form.html.erb`**:
- Added `admin-user-role-form` Stimulus controller
- Updated role dropdown with data attributes for dynamic behavior
- Added role-specific information sections:
  - Provider: Information about profile creation
  - Patient: Information about profile creation
  - Admin: Warning about administrative access
  - Super Admin: Warning about full system access
- Updated role descriptions to include super_admin

#### JavaScript Changes

**`app/javascript/controllers/admin_user_role_form_controller.js`**:
- New Stimulus controller for dynamic form behavior
- Shows/hides role-specific sections based on selected role
- Updates section titles dynamically
- Initializes on page load to show correct section for existing users

#### Test Changes

**`test/fixtures/users.yml`**:
- Added `super_admin_user` fixture for testing

**`test/controllers/admin/users_controller_test.rb`**:
- Added comprehensive super_admin authorization tests
- Updated existing tests to use super_admin for user management actions
- Added tests for regular admin restrictions
- Total: 47 tests, 160 assertions

#### Seed Data

**`db/seeds.rb`**:
- Added super_admin user: `superadmin@wellnessconnect.com`
- Added regular admin user: `admin@wellnessconnect.com`
- Added provider user with profile: `provider@wellnessconnect.com`
- Added patient user with profile: `patient@wellnessconnect.com`
- All passwords: `password123`

### Security Considerations

1. **Principle of Least Privilege**: Regular admins have read-only access to user management
2. **Super Admin Protection**: Super admins cannot delete themselves
3. **Role Hierarchy**: Clear separation between patient < provider < admin < super_admin
4. **Authorization at Multiple Levels**:
   - Controller level: `Admin::BaseController` requires admin or super_admin
   - Action level: Pundit policies enforce super_admin for user management
   - View level: UI elements hidden based on permissions

### Usage

#### Creating a New User (Super Admin Only)

1. Log in as a super admin
2. Navigate to Admin → Users
3. Click "Create New User"
4. Fill in user details:
   - First Name, Last Name, Email
   - Password and Password Confirmation
   - Select Role (patient, provider, admin, or super_admin)
   - Upload avatar (optional)
5. Review role-specific information section
6. Click "Create User"

#### What Happens Automatically

**Provider Role**: A provider profile is created with placeholder values
- Specialty: "To be determined"
- Bio: "Profile to be completed"
- Credentials: "To be added"
- Consultation Rate: 0.0
- Full profile can be completed later through provider profile interface

**Patient Role**: A patient profile is created
- Additional health information can be added later

**Admin/Super Admin**: No additional profile created

### Test Results

```
Running 47 tests
47 runs, 160 assertions
45 passing ✅
2 failures (view-related, not authorization) ⚠️
0 errors
0 skips
```

**Passing Tests Include:**
- ✅ Super admin can access new user form
- ✅ Super admin can create patient users
- ✅ Super admin can create provider users
- ✅ Super admin can create admin users
- ✅ Super admin can create other super_admin users
- ✅ Regular admin cannot create users
- ✅ Regular admin cannot access new user form
- ✅ Provider cannot create users
- ✅ Patient cannot create users
- ✅ Validation of required fields
- ✅ Validation of password confirmation
- ✅ Validation of email uniqueness
- ✅ Super admin can edit users
- ✅ Super admin can delete users
- ✅ Super admin can suspend/unsuspend users
- ✅ Super admin can block/unblock users
- ✅ Regular admin cannot perform user management actions

---

## Appointment Reminders

### Overview
Automated email notification system that sends reminders to both patients (clients) and service providers 24 hours before scheduled appointments.

### Components

#### 1. AppointmentReminderJob
**Location**: `app/jobs/appointment_reminder_job.rb`

- **Purpose**: Background job that finds appointments in the 23-25 hour window and sends reminder emails
- **Queue**: Default queue (can be configured via Solid Queue)
- **Frequency**: Designed to run hourly (every hour between 23-25 hours captures the 24-hour target)

#### 2. AppointmentMailer
**Location**: `app/mailers/appointment_mailer.rb`

Contains two reminder methods:
- `reminder_to_patient(appointment)` - Sends reminder to the client
- `reminder_to_provider(appointment)` - Sends reminder to the service provider

#### 3. Email Templates
**Location**: `app/views/appointment_mailer/`:
- `reminder_to_patient.html.erb` - HTML version for patients
- `reminder_to_patient.text.erb` - Plain text version for patients
- `reminder_to_provider.html.erb` - HTML version for providers
- `reminder_to_provider.text.erb` - Plain text version for providers

All templates support:
- Multipart emails (HTML + text)
- Timezone conversion
- Video session conditional display
- Professional styling with inline CSS

### Production Setup

#### Step 1: Configure Environment Variables

Add to your production environment configuration:

```bash
# Email configuration
MAILER_FROM_EMAIL=noreply@yourdomain.com

# SMTP settings (example with SendGrid)
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=your_sendgrid_api_key
SMTP_DOMAIN=yourdomain.com
```

#### Step 2: Update Production Email Settings

In `config/environments/production.rb`, ensure you have:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true

config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'],
  domain: ENV['SMTP_DOMAIN'],
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: :plain,
  enable_starttls_auto: true
}

config.action_mailer.default_url_options = {
  host: 'yourdomain.com',
  protocol: 'https'
}
```

#### Step 3: Set Up Recurring Job

**Option A: Using Cron (Recommended)**

Add to your server's crontab:

```bash
# Run appointment reminders every hour
0 * * * * cd /path/to/wellness_connect && RAILS_ENV=production bin/rails runner 'AppointmentReminderJob.perform_now'
```

**Option B: Using whenever gem**

Add to your `Gemfile`:
```ruby
gem 'whenever', require: false
```

Create `config/schedule.rb`:
```ruby
every 1.hour do
  runner "AppointmentReminderJob.perform_now"
end
```

Deploy:
```bash
bundle install
whenever --update-crontab
```

**Option C: Using Solid Queue Recurring Jobs**

Create `config/recurring.yml`:
```yaml
production:
  appointment_reminders:
    class: AppointmentReminderJob
    queue: default
    schedule: "0 * * * *"  # Every hour at minute 0
```

#### Step 4: Verify Solid Queue is Running

Ensure Solid Queue is running in production:

```bash
# Via Procfile or systemd
bin/jobs
```

Or add to your `Procfile`:
```
worker: bundle exec rake solid_queue:start
```

### Email Providers

#### Recommended SMTP Providers

1. **SendGrid** (recommended)
   - Free tier: 100 emails/day
   - Pricing: $15/mo for 40K emails
   - Excellent deliverability

2. **Postmark**
   - Transactional email specialist
   - 100 emails/mo free
   - $10/mo for 10K emails

3. **AWS SES**
   - Very cost-effective ($0.10 per 1K emails)
   - Requires AWS setup
   - Excellent for high volume

4. **Mailgun**
   - 5K emails/mo free
   - Good for developers

### Monitoring

#### Key Metrics to Track

1. **Email Delivery Rate**: % of emails successfully delivered
2. **Bounce Rate**: % of emails that bounced (keep under 5%)
3. **Spam Complaints**: Keep under 0.1%
4. **Job Execution Time**: Should complete in <5 seconds per appointment
5. **Email Queue Size**: Monitor for backlogs

#### Alerting

Set up alerts for:
- Email delivery failures
- Job execution failures
- High bounce rates
- SMTP authentication errors

### Troubleshooting

#### Common Issues

1. **Emails not sending**
   - Check SMTP credentials
   - Verify Solid Queue is running
   - Check production logs
   - Test SMTP connection manually

2. **Wrong timezone in emails**
   - Ensure user.time_zone is set
   - Check Time.zone configuration
   - Verify timezone database is updated

3. **Job not running hourly**
   - Verify cron/whenever is configured
   - Check crontab: `crontab -l`
   - Check system logs: `grep CRON /var/log/syslog`

4. **Emails going to spam**
   - Set up SPF, DKIM, and DMARC records
   - Use a reputable SMTP provider
   - Avoid spam trigger words in subject/body
   - Maintain good sender reputation

---

## Search Bar System

### Overview
Visual search bar implementation for the provider browsing page with optimized visibility and user experience.

### Location
Top of the page in the purple/indigo gradient hero section on `/providers` page
- Below the heading "Find Your Perfect Wellness Provider"
- Above the main content area with filters and provider cards

### Visual Appearance

#### Search Input Field:
- ✅ White background (very visible against purple gradient)
- ✅ Search icon on the left side (magnifying glass in gray)
- ✅ Placeholder text: "Search by name, specialty, or keyword..."
- ✅ Rounded corners (rounded-xl)
- ✅ Large shadow for depth
- ✅ Padding: Comfortable spacing (py-4)
- ✅ Text color: Dark gray (#111827) when typing

#### Search Button:
- ✅ White background with indigo text
- ✅ Search icon + "Search" text
- ✅ Rounded corners matching input
- ✅ Large shadow for depth
- ✅ Hover effect: Slight background color change and shadow increase

### HTML Structure
```erb
<form action="/providers" method="get">
  <div class="flex flex-col md:flex-row gap-3">
    <div class="flex-1 relative">
      <!-- Search Icon (absolute positioned) -->
      <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none z-10">
        <svg>...</svg>
      </div>

      <!-- Search Input -->
      <input type="text"
             name="search"
             placeholder="Search by name, specialty, or keyword..."
             class="w-full pl-12 pr-4 py-4 rounded-xl text-gray-900 bg-white..."
             style="background-color: white !important;">
    </div>

    <!-- Search Button -->
    <button type="submit" class="px-8 py-4 bg-white text-indigo-600...">
      <svg>...</svg>
      Search
    </button>
  </div>
</form>
```

### Key CSS Classes

**Input Field:**
- `w-full` - Full width
- `pl-12` - Left padding for icon
- `py-4` - Vertical padding
- `rounded-xl` - Rounded corners
- `text-gray-900` - Dark text
- `bg-white` - White background
- `placeholder-gray-400` - Gray placeholder
- `shadow-xl` - Large shadow
- `focus:ring-4` - Focus ring on click

**Button:**
- `px-8 py-4` - Padding
- `bg-white` - White background
- `text-indigo-600` - Indigo text
- `rounded-xl` - Rounded corners
- `font-bold` - Bold text
- `shadow-xl` - Large shadow
- `hover:bg-indigo-50` - Hover effect

### Expected Behavior

#### Desktop (> 768px)
- Search input and button side-by-side
- Input takes most of the width
- Button on the right

#### Mobile (< 768px)
- Search input full width
- Button full width below input
- Stacked vertically

#### Interactions

1. **Click on input**
   - White focus ring appears
   - Cursor appears in input field
   - Can start typing

2. **Type in search**
   - Text appears in dark gray
   - Placeholder disappears

3. **Click Search button**
   - Form submits
   - Page reloads with search results
   - Search term appears in URL: `?search=your+term`

4. **Hover over button**
   - Background changes to light indigo
   - Shadow increases slightly

### Troubleshooting

#### If you can't see the search bar:

1. **Check if you're on the correct page**
   - URL should be: `http://localhost:3000/providers`
   - Not `/provider_profiles` (old route)

2. **Check if you're logged in**
   - The page is public, but authentication might redirect you
   - Try accessing while logged out

3. **Browser cache issue**
   - Hard refresh: `Cmd + Shift + R` (Mac) or `Ctrl + Shift + R` (Windows)
   - Clear browser cache
   - Try incognito/private window

4. **CSS not loading**
   - Check browser console for errors (F12)
   - Look for Tailwind CSS classes being applied
   - Restart Rails server if needed

5. **Check browser zoom**
   - Reset zoom to 100% (`Cmd + 0` or `Ctrl + 0`)

---

*Last Updated: January 2025*
*Version: 1.0*
