# Comprehensive Provider Profile Examples

This directory contains detailed examples of how to create rich, comprehensive provider profiles using all available `ProviderProfile` model attributes.

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

#### **`areas_of_expertise`** (text, comma-separated)
Multiple specialization areas within the provider's field. Stored as comma-separated text, accessible via `areas_of_expertise_array` helper method.

**Example (Software Consultant):**
```ruby
areas_of_expertise: "System Architecture Design, Cloud Infrastructure, Backend Development, API Design, Database Optimization, DevOps & CI/CD"
```

**Example (Health Practitioner):**
```ruby
areas_of_expertise: "Chronic Disease Management, Digestive Health, Hormone Balance, Autoimmune Conditions, Nutritional Therapy"
```

#### **`treatment_modalities`** (text, comma-separated)
Treatment methods and therapeutic approaches - primarily for health practitioners. Accessible via `treatment_modalities_array` helper method.

**Example (Naturopathic Doctor):**
```ruby
treatment_modalities: "Clinical Nutrition, Botanical Medicine, Homeopathy, Acupuncture, IV Nutrient Therapy, Bio-identical Hormone Replacement"
```

**Note:** Non-health providers can leave this field empty or repurpose for methodologies/approaches.

#### **`philosophy`** (text)
Provider's professional philosophy, approach, or treatment principles. Free-form text field for expressing core values and methods.

**Example (Consultant):**
```ruby
philosophy: "I believe in pragmatic solutions that balance technical excellence with business realities. My consulting approach emphasizes practical solutions, education-first mindset, and data-driven decisions."
```

**Example (Health Practitioner):**
```ruby
philosophy: "I believe in treating the whole person, not just symptoms. My approach follows the six principles of naturopathic medicine: First Do No Harm, The Healing Power of Nature, Identify Root Causes, Doctor as Teacher, Treat the Whole Person, and Prevention is the Best Cure."
```

#### **`session_formats`** (text, comma-separated)
Available consultation formats and delivery methods. Accessible via `session_formats_array` helper method.

**Examples:**
```ruby
# Consultant
session_formats: "Video Consultation (Zoom/Google Meet), Screen Sharing for Code Review, Asynchronous Code Review via GitHub, In-Person (Bay Area)"

# Health Practitioner
session_formats: "In-Person Consultation, Telemedicine Video Visits, Phone Consultation, Hybrid Care Plans, Group Workshops"
```

#### **`industries_served`** (text, comma-separated)
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

### 1. **software_engineer_profile_example.rb**
Demonstrates a complete Software Engineering & Data Consultant profile including:
- Technical expertise areas (10 areas listed)
- Industries served (8 industries)
- Session formats (5 formats including screen sharing and async code review)
- Professional philosophy for consultants
- 4 service offerings with detailed descriptions
- 2 weeks of availability slots

### 2. **naturopathic_practitioner_profile_example.rb**
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
