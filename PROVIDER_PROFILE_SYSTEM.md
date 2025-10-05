# Provider Profile System Documentation

## Overview

The WellnessConnect Provider Profile System is a comprehensive, modern, and sophisticated profile page implementation designed to showcase healthcare providers in a professional and trustworthy manner. The system includes media gallery support, interactive features, and a premium user experience.

## Features

### 1. Hero/Header Section
- **Premium Design**: Gradient background (indigo to purple) with decorative elements
- **Provider Avatar**: Large circular profile photo with verification badge
- **Provider Information**: Name, credentials, specialty, and years of experience
- **Rating Display**: 5-star rating system with review count
- **Quick Action Buttons**: Book Appointment, Message, and Share functionality
- **Responsive Layout**: Adapts beautifully from mobile to desktop

### 2. About Section
- **Professional Bio**: Rich text biography with proper formatting
- **Experience Highlights**: Years of experience displayed prominently
- **Education**: Detailed educational background
- **Certifications**: Professional certifications and credentials
- **Languages**: Multi-language support with visual tags
- **Visual Design**: Icon-based information cards with color-coded sections

### 3. Media Gallery
- **Multi-Format Support**:
  - Images (JPEG, PNG, WebP) - up to 10MB each
  - Videos (MP4, MOV, AVI) - up to 100MB each
  - Audio (MP3, WAV, OGG) - up to 50MB each
  - PDFs (certifications, articles) - up to 20MB each
- **Interactive Lightbox**: Full-screen media viewer with navigation
- **Keyboard Navigation**: Arrow keys for next/previous, Escape to close
- **Responsive Grid**: 2-4 columns depending on screen size
- **Visual Indicators**: Color-coded badges for media types

### 4. Services Section
- **Service Cards**: Modern card design with gradient backgrounds
- **Pricing Display**: Clear pricing with session duration
- **Service Details**: Name, description, duration, and price
- **Booking Integration**: Direct links to booking system
- **Active/Inactive Status**: Only shows active services
- **Empty State**: Friendly message when no services available

### 5. Availability & Booking
- **Sidebar Widget**: Sticky booking widget with consultation rate
- **Next Available Slots**: Shows upcoming 5 available time slots
- **Quick Booking**: One-click booking for authenticated patients
- **Call-to-Action**: Clear CTAs for booking appointments
- **Empty State**: Informative message when no slots available

### 6. Reviews & Testimonials
- **Rating Summary**: Large rating display with breakdown by stars
- **Testimonial Carousel**: Rotating client testimonials
- **Verified Reviews**: Visual indicators for verified reviews
- **Rating Distribution**: Visual bar chart showing rating breakdown
- **Write Review CTA**: Encourages patients to leave reviews
- **Carousel Controls**: Previous/Next buttons and indicators

### 7. Contact & Location
- **Contact Information**: Phone, email, office address
- **Website Link**: External link to provider's website
- **Social Media Integration**: LinkedIn, Twitter, Facebook, Instagram
- **Visual Icons**: Platform-specific icons and colors
- **Clickable Links**: Direct links to contact methods

### 8. Quick Stats Widget
- **Key Metrics**: Reviews, experience, services, response time
- **Visual Design**: Gradient background with icon-based stats
- **Trust Badges**: Verified and Secure badges
- **Sticky Positioning**: Stays visible while scrolling

## Technical Implementation

### Database Schema

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

### Active Storage Attachments

```ruby
# ProviderProfile model
has_one_attached :avatar
has_many_attached :gallery_images
has_many_attached :gallery_videos
has_many_attached :gallery_audio
has_many_attached :documents
```

### File Validations

- **Avatar**: JPEG/PNG/WebP, max 5MB
- **Gallery Images**: JPEG/PNG/WebP, max 10MB each
- **Gallery Videos**: MP4/MOV/AVI, max 100MB each
- **Gallery Audio**: MP3/WAV/OGG, max 50MB each
- **Documents**: PDF only, max 20MB each

### Stimulus Controllers

#### 1. Media Gallery Controller (`media_gallery_controller.js`)
- Opens lightbox with selected media
- Navigates between media items
- Handles keyboard shortcuts
- Supports all media types (image, video, audio, PDF)
- Click-outside-to-close functionality

#### 2. Smooth Scroll Controller (`smooth_scroll_controller.js`)
- Smooth scrolling to section anchors
- Accounts for fixed navbar offset
- Enhances navigation experience

#### 3. Carousel Controller (`carousel_controller.js`)
- Testimonial carousel functionality
- Auto-play support (optional)
- Manual navigation (previous/next)
- Indicator dots for slide position
- Keyboard accessible

### View Structure

```
app/views/provider_profiles/
├── show.html.erb (main profile page)
└── sections/
    ├── _about.html.erb
    ├── _media_gallery.html.erb
    ├── _services.html.erb
    ├── _reviews.html.erb
    ├── _booking_widget.html.erb
    ├── _contact_info.html.erb
    └── _quick_stats.html.erb
```

## Accessibility Features

### WCAG 2.1 AA Compliance
- ✅ Proper heading hierarchy (h1, h2, h3)
- ✅ ARIA labels for interactive elements
- ✅ Keyboard navigation support
- ✅ Alt text for images
- ✅ High contrast ratios (4.5:1 minimum)
- ✅ Focus indicators on interactive elements
- ✅ Screen reader compatible
- ✅ Semantic HTML structure

### Keyboard Navigation
- **Tab**: Navigate through interactive elements
- **Enter/Space**: Activate buttons and links
- **Arrow Keys**: Navigate media gallery (when lightbox open)
- **Escape**: Close lightbox/modals

## Responsive Design

### Breakpoints
- **Mobile**: < 768px (1 column layout)
- **Tablet**: 768px - 1024px (2 column layout)
- **Desktop**: > 1024px (3 column layout with sidebar)

### Mobile Optimizations
- Hamburger menu for navigation tabs
- Stacked layout for hero section
- Touch-friendly button sizes (minimum 44x44px)
- Optimized image loading
- Reduced motion for animations

## Usage Guide

### For Providers

#### Uploading Media
1. Navigate to Edit Profile
2. Use file upload fields for:
   - Profile avatar
   - Gallery images
   - Videos
   - Audio files
   - PDF documents
3. Save changes

#### Managing Services
1. Add services through Services section
2. Set pricing and duration
3. Mark services as active/inactive
4. Services automatically appear on profile

#### Setting Availability
1. Create availability slots
2. Slots automatically appear in booking widget
3. Patients can book directly from profile

### For Patients

#### Viewing Profiles
1. Browse providers at `/providers`
2. Click on provider to view full profile
3. Scroll through sections or use navigation tabs

#### Booking Appointments
1. View available slots in sidebar
2. Click "Book" on desired slot
3. Complete booking process

#### Leaving Reviews
1. Sign in as patient
2. Click "Write a Review" button
3. Submit review (feature to be implemented)

## SEO Optimization

### Meta Tags
- Provider name in title
- Specialty and credentials in description
- Structured data for local business
- Open Graph tags for social sharing

### Performance
- Lazy loading for images
- Optimized asset delivery
- Minimal JavaScript bundle
- Fast page load times

## Security

### File Upload Security
- Content type validation
- File size limits
- Virus scanning (recommended for production)
- Secure file storage with Active Storage

### Access Control
- Pundit policies for authorization
- Only profile owners can edit
- Public viewing for all users
- Secure file URLs

## Testing

### System Tests
- 20+ comprehensive test cases
- Hero section display
- Navigation functionality
- About section content
- Services display
- Reviews and testimonials
- Booking widget
- Contact information
- Accessibility compliance
- Responsive design

### Running Tests
```bash
# Run all provider profile tests
bin/rails test:system test/system/provider_profile_test.rb

# Run specific test
bin/rails test:system test/system/provider_profile_test.rb -n test_name
```

## Future Enhancements

### Planned Features
- [ ] Real-time messaging system
- [ ] Video consultation integration
- [ ] Advanced booking calendar
- [ ] Review moderation system
- [ ] Analytics dashboard for providers
- [ ] Multi-language support
- [ ] Map integration for office location
- [ ] Appointment reminders
- [ ] Payment processing integration
- [ ] Provider verification workflow

## Support

For questions or issues:
- Check documentation in `/docs`
- Review test cases for examples
- Contact development team

## License

Copyright © 2025 WellnessConnect. All rights reserved.

