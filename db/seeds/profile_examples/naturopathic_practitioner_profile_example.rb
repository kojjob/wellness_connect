# Example: Creating a comprehensive Naturopathic Health Practitioner Provider Profile
# This demonstrates the use of treatment_modalities and health-focused attributes

# 1. Create the user account
user = User.create!(
  email: "dr.sarah.martinez@holistichealth.com",
  password: "SecurePassword123!",
  password_confirmation: "SecurePassword123!",
  first_name: "Dr. Sarah",
  last_name: "Martinez",
  role: :provider,
  time_zone: "America/Denver"
)

# 2. Create the comprehensive provider profile
provider_profile = user.create_provider_profile!(
  # Core Information
  specialty: "Naturopathic Medicine & Holistic Health",

  bio: "Board-certified naturopathic doctor with 15+ years of clinical experience specializing in integrative medicine and natural healing. I help clients achieve optimal wellness through evidence-based natural therapies, nutrition, and lifestyle medicine. My practice focuses on identifying and treating the root causes of health issues rather than just managing symptoms.\n\nI work with individuals seeking natural solutions for chronic conditions, preventive health optimization, hormone balance, digestive health, and overall vitality. My integrative approach combines the wisdom of traditional healing with modern scientific research to create personalized treatment plans that support your body's innate healing abilities.",

  # Education & Credentials
  education: "Doctor of Naturopathic Medicine (ND), Bastyr University; B.S. Biology, University of Colorado Boulder; Postgraduate Training in Functional Medicine, Institute for Functional Medicine",

  credentials: "Licensed Naturopathic Doctor (ND), Board Certified in Naturopathic Medicine (DHANP), Certified Functional Medicine Practitioner (CFMP), Advanced Training in Clinical Nutrition",

  certifications: "Diplomate of the Homeopathic Academy of Naturopathic Physicians (DHANP), Certified in Advanced Botanical Medicine, Acupuncture License (Colorado), IV Therapy Certification",

  years_of_experience: 15,

  # Pricing
  consultation_rate: 135.00,

  # NEW FIELDS: Areas of Expertise (comma-separated)
  areas_of_expertise: "Chronic Disease Management, Digestive Health & Gut Microbiome, Hormone Balance (Thyroid/Adrenal/Reproductive), Autoimmune Conditions, Nutritional Therapy, Detoxification Support, Stress Management & Mental Wellness, Women's Health & Fertility, Preventive Medicine, Integrative Cancer Support",

  # NEW FIELDS: Treatment Modalities (comma-separated) - HEALTH-SPECIFIC
  treatment_modalities: "Clinical Nutrition & Dietary Counseling, Botanical Medicine (Herbal Therapy), Homeopathy, Acupuncture & Traditional Chinese Medicine, IV Nutrient Therapy, Bio-identical Hormone Replacement, Detoxification Protocols, Lifestyle Medicine, Mind-Body Therapies, Functional Lab Testing",

  # NEW FIELDS: Industries Served - Not applicable for health practitioners, can leave empty or use for patient types
  industries_served: "Individual Patients, Wellness-Focused Corporations, Athletic Teams, Healthcare Collaboration (Integrative Medicine Clinics)",

  # NEW FIELDS: Session Formats (comma-separated)
  session_formats: "In-Person Consultation (Boulder Office), Telemedicine Video Visits, Phone Consultation, Hybrid Care Plans, Group Wellness Workshops",

  # NEW FIELDS: Philosophy
  philosophy: "I believe in treating the whole person, not just isolated symptoms. My approach is rooted in six fundamental principles of naturopathic medicine:\n\n• First, Do No Harm (Primum Non Nocere): Using the least invasive, most natural therapies first\n• The Healing Power of Nature (Vis Medicatrix Naturae): Supporting your body's inherent self-healing abilities\n• Identify and Treat the Root Cause (Tolle Causam): Going beyond symptom management\n• Doctor as Teacher (Docere): Empowering you with knowledge and self-care tools\n• Treat the Whole Person: Addressing physical, mental, emotional, and spiritual wellness\n• Prevention is the Best Cure: Proactive health optimization and disease prevention\n\nEvery treatment plan is personalized to your unique biochemistry, lifestyle, and health goals. I partner with you on your healing journey, providing education, support, and natural therapies that work with your body, not against it.",

  # Languages
  languages: "English, Spanish",

  # Contact & Social Media
  phone: "+1 (303) 555-0189",
  website: "https://drsamartinez.com",
  linkedin_url: "https://linkedin.com/in/dr-sarah-martinez-nd",
  instagram_url: "https://instagram.com/dr.sarah.nd",
  facebook_url: "https://facebook.com/DrSarahMartinezND",
  office_address: "2500 Pearl Street, Boulder, CO 80302"
)

# 3. Create service offerings
services = [
  {
    name: "Comprehensive Initial Consultation",
    description: "In-depth 90-minute first visit including complete health history review, physical exam, functional medicine assessment, and personalized treatment plan development. We'll explore your health concerns, review any existing lab work, discuss nutrition and lifestyle factors, and create a roadmap for your healing journey.\n\nIncludes:\n• Detailed health history and symptom analysis\n• Physical examination and vital signs assessment\n• Review of current medications and supplements\n• Functional medicine evaluation\n• Personalized treatment plan with natural therapies\n• Nutritional and lifestyle recommendations\n• Lab testing recommendations if needed\n\nBest For:\n• New patients seeking comprehensive natural health solutions\n• Chronic health conditions requiring root cause analysis\n• Preventive health optimization\n• Second opinion on existing health challenges",
    duration_minutes: 90,
    price: 250.00,
    is_active: true
  },
  {
    name: "Follow-Up Consultation",
    description: "60-minute follow-up visit to monitor progress, adjust treatment protocols, review lab results, and continue your healing journey. We'll assess improvements, address any new concerns, and refine your treatment plan based on your body's response.\n\nIncludes:\n• Progress assessment and symptom tracking\n• Lab result review and interpretation\n• Treatment plan adjustments\n• Prescription refills (botanical/nutritional supplements)\n• Continued education and support\n• Goal setting and wellness planning\n\nBest For:\n• Ongoing care and protocol adjustments\n• Lab result review and discussion\n• Treatment plan refinement\n• Preventive health maintenance",
    duration_minutes: 60,
    price: 135.00,
    is_active: true
  },
  {
    name: "Nutritional Therapy & Meal Planning",
    description: "Specialized 60-minute session focused on personalized nutritional therapy, dietary protocols, and meal planning tailored to your health goals and conditions. I'll provide evidence-based nutritional recommendations, food sensitivity guidance, and practical meal planning strategies.\n\nIncludes:\n• Nutritional assessment and deficiency analysis\n• Personalized dietary protocol (Paleo, AIP, Mediterranean, etc.)\n• Food sensitivity and elimination diet guidance\n• Customized meal plans and recipes\n• Supplement recommendations for nutritional support\n• Shopping lists and food preparation tips\n\nBest For:\n• Digestive health conditions (IBS, SIBO, Crohn's, etc.)\n• Autoimmune disease management\n• Weight optimization and metabolic health\n• Food sensitivities and allergies\n• Athletic performance nutrition",
    duration_minutes: 60,
    price: 150.00,
    is_active: true
  },
  {
    name: "Hormone Balance Consultation",
    description: "Specialized 75-minute consultation focused on hormone health including thyroid, adrenal, and reproductive hormones. We'll review symptoms, order appropriate lab testing, and create a comprehensive natural hormone balancing protocol.\n\nIncludes:\n• Complete hormone symptom assessment\n• Functional hormone testing recommendations (salivary, urine, blood)\n• Bio-identical hormone therapy options\n• Herbal and nutritional hormone support protocols\n• Lifestyle modifications for hormone balance\n• Stress management strategies for adrenal health\n\nBest For:\n• Thyroid conditions (hypothyroid, Hashimoto's)\n• Adrenal fatigue and stress-related issues\n• Women's hormone imbalances (PMS, PCOS, menopause)\n• Men's hormone optimization\n• Fertility support",
    duration_minutes: 75,
    price: 180.00,
    is_active: true
  },
  {
    name: "Quick Check-In & Prescription Refill",
    description: "Brief 30-minute appointment for established patients needing prescription refills, minor treatment adjustments, or quick health check-ins. Ideal for maintaining wellness between comprehensive visits.\n\nIncludes:\n• Brief symptom update\n• Prescription refills (supplements, botanicals)\n• Minor protocol adjustments\n• Quick questions and concerns addressed\n\nBest For:\n• Established patients on stable protocols\n• Prescription refills and renewals\n• Quick health concerns or questions\n• Maintenance between comprehensive visits",
    duration_minutes: 30,
    price: 75.00,
    is_active: true
  }
]

services.each do |service_attrs|
  provider_profile.services.create!(service_attrs)
end

# 4. Create sample availability slots (Monday-Thursday, 8 AM - 5 PM)
# Generate availability for next 2 weeks
require 'active_support/core_ext/integer/time'

start_date = Date.today
end_date = start_date + 14.days

(start_date..end_date).each do |date|
  # Skip weekends and Fridays (4-day work week)
  next if date.wday == 0 || date.wday == 6 || date.wday == 5

  # Create morning slots (8 AM - 12 PM)
  [ 8, 9, 10, 11 ].each do |hour|
    start_time = Time.zone.parse("#{date} #{hour}:00")
    end_time = start_time + 1.hour

    provider_profile.availabilities.create!(
      start_time: start_time,
      end_time: end_time,
      is_booked: false
    )
  end

  # Create afternoon slots (1 PM - 5 PM)
  [ 13, 14, 15, 16 ].each do |hour|
    start_time = Time.zone.parse("#{date} #{hour}:00")
    end_time = start_time + 1.hour

    provider_profile.availabilities.create!(
      start_time: start_time,
      end_time: end_time,
      is_booked: false
    )
  end
end

puts "✅ Naturopathic Health Practitioner profile created successfully!"
puts "   User: #{user.email}"
puts "   Provider: #{provider_profile.full_name}"
puts "   Specialty: #{provider_profile.specialty}"
puts "   Services: #{provider_profile.services.count}"
puts "   Availabilities: #{provider_profile.availabilities.count}"
puts ""
puts "📊 Health-Focused Profile Attributes:"
puts "   Areas of Expertise: #{provider_profile.areas_of_expertise_array.count} areas"
puts "   Treatment Modalities: #{provider_profile.treatment_modalities_array.count} modalities"
puts "   Session Formats: #{provider_profile.session_formats_array.count} formats"
puts "   Philosophy: #{provider_profile.philosophy.present? ? 'Yes (Naturopathic Principles)' : 'No'}"
puts "   Languages: #{provider_profile.languages_array.join(', ')}"
puts "   Years of Experience: #{provider_profile.years_of_experience}"
