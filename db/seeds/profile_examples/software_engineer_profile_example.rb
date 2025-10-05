# Example: Creating a comprehensive Software Engineer/Data Consultant Provider Profile
# This demonstrates how to use all the ProviderProfile attributes including the new fields

# 1. Create the user account
user = User.create!(
  email: "alex.chen@techconsult.com",
  password: "SecurePassword123!",
  password_confirmation: "SecurePassword123!",
  first_name: "Alex",
  last_name: "Chen",
  role: :provider,
  time_zone: "America/Los_Angeles"
)

# 2. Create the comprehensive provider profile
provider_profile = user.create_provider_profile!(
  # Core Information
  specialty: "Software Engineering & Data Science Consulting",

  bio: "Results-driven software engineering and data science consultant with 12+ years of experience helping businesses leverage technology for growth. I specialize in technical architecture design, data-driven decision making, and building scalable software solutions. My approach combines deep technical expertise with business acumen to deliver practical solutions that drive measurable outcomes.\n\nI work with startups, SMBs, and enterprise teams on everything from MVP development to legacy system modernization. Whether you're launching a new product, optimizing your data infrastructure, or need strategic technical guidance, I provide actionable insights backed by industry best practices.",

  # Education & Credentials
  education: "M.S. Computer Science, Stanford University; B.S. Computer Engineering, MIT",

  credentials: "AWS Certified Solutions Architect - Professional, Google Cloud Professional Data Engineer, Certified Scrum Master (CSM)",

  certifications: "AWS Solutions Architect Professional, GCP Data Engineer, Azure Solutions Architect, Certified Kubernetes Administrator (CKA)",

  years_of_experience: 12,

  # Pricing
  consultation_rate: 200.00,

  # NEW FIELDS: Areas of Expertise (comma-separated)
  areas_of_expertise: "System Architecture Design, Cloud Infrastructure (AWS/GCP/Azure), Backend Development (Python/Ruby/Node.js/Go), API Design (REST/GraphQL/gRPC), Database Optimization, DevOps & CI/CD, Data Pipeline Architecture, Machine Learning Deployment, Technical Leadership, Agile/Scrum Implementation",

  # NEW FIELDS: Industries Served (comma-separated)
  industries_served: "SaaS & Cloud Services, E-commerce & Marketplaces, FinTech & Financial Services, HealthTech & Medical Platforms, EdTech & Learning Platforms, Media & Content Platforms, B2B Enterprise Software, Consumer Mobile Applications",

  # NEW FIELDS: Session Formats (comma-separated)
  session_formats: "Video Consultation (Zoom/Google Meet), Screen Sharing for Code Review, Collaborative Documentation (Google Docs/Notion), Asynchronous Code Review via GitHub, In-Person Consultation (Bay Area)",

  # NEW FIELDS: Philosophy
  philosophy: "Technology should enable business growth, not complicate it. I believe in pragmatic solutions that balance technical excellence with business realities. My consulting approach emphasizes:\n\n• Practical Over Perfect: Solutions that work today while positioning for tomorrow\n• Education-First: Empowering teams to maintain and evolve systems independently\n• Data-Driven Decisions: Using metrics to validate technical and business choices\n• Long-term Thinking: Building foundations that scale with your business\n• Collaborative Partnership: Working alongside your team, not dictating from outside",

  # Languages
  languages: "English, Mandarin Chinese",

  # Contact & Social Media
  phone: "+1 (415) 555-0123",
  website: "https://alexchen.tech",
  linkedin_url: "https://linkedin.com/in/alexchen-techconsult",
  twitter_url: "https://twitter.com/alexchen_tech",
  office_address: "Remote (Based in San Francisco Bay Area)"
)

# 3. Create service offerings
services = [
  {
    name: "Technical Architecture Consultation",
    description: "Comprehensive review of your technical architecture, scalability planning, and technology stack optimization. I'll analyze your current system, identify bottlenecks, and provide a detailed roadmap for improvement. Includes architecture diagrams, technology recommendations, and implementation priorities.\n\nBest For:\n• Startups planning to scale\n• Companies experiencing performance issues\n• Teams modernizing legacy systems\n• Technical debt assessment",
    duration_minutes: 90,
    price: 300.00,
    is_active: true
  },
  {
    name: "Data Strategy & Analytics Consultation",
    description: "Strategic session focused on leveraging data for business growth. We'll discuss data collection strategies, analytics infrastructure, KPI tracking, and building data-driven decision-making processes. Includes recommendations for tools, platforms, and implementation approaches.\n\nBest For:\n• Businesses wanting to become more data-driven\n• Companies struggling with data silos\n• Teams evaluating analytics platforms\n• Organizations building data warehouses",
    duration_minutes: 60,
    price: 200.00,
    is_active: true
  },
  {
    name: "Code Review & Best Practices Session",
    description: "In-depth code review focusing on code quality, security vulnerabilities, performance optimization, and adherence to industry best practices. I'll provide specific refactoring recommendations, identify technical debt, and suggest improvements to your development workflow.\n\nBest For:\n• Development teams seeking external review\n• Startups preparing for investor due diligence\n• Teams implementing new coding standards\n• Pre-production launch quality assurance",
    duration_minutes: 60,
    price: 200.00,
    is_active: true
  },
  {
    name: "Career Mentorship for Engineers",
    description: "One-on-one mentorship session for software engineers and data scientists looking to advance their careers. Topics include: technical skill development, interview preparation (FAANG companies), career trajectory planning, salary negotiation, and transitioning between specializations.\n\nBest For:\n• Engineers preparing for senior/staff promotions\n• Professionals interviewing at top tech companies\n• Developers transitioning to data science or vice versa\n• Individual contributors considering management paths",
    duration_minutes: 45,
    price: 150.00,
    is_active: true
  }
]

services.each do |service_attrs|
  provider_profile.services.create!(service_attrs)
end

# 4. Create sample availability slots (Monday-Friday, 9 AM - 5 PM PST)
# Generate availability for next 2 weeks
require 'active_support/core_ext/integer/time'

start_date = Date.today
end_date = start_date + 14.days

(start_date..end_date).each do |date|
  # Skip weekends
  next if date.wday == 0 || date.wday == 6

  # Create morning slots (9 AM - 12 PM)
  [9, 10, 11].each do |hour|
    start_time = Time.zone.parse("#{date} #{hour}:00")
    end_time = start_time + 1.hour

    provider_profile.availabilities.create!(
      start_time: start_time,
      end_time: end_time,
      is_booked: false
    )
  end

  # Create afternoon slots (1 PM - 5 PM)
  [13, 14, 15, 16].each do |hour|
    start_time = Time.zone.parse("#{date} #{hour}:00")
    end_time = start_time + 1.hour

    provider_profile.availabilities.create!(
      start_time: start_time,
      end_time: end_time,
      is_booked: false
    )
  end
end

puts "✅ Software Engineer/Data Consultant profile created successfully!"
puts "   User: #{user.email}"
puts "   Provider: #{provider_profile.full_name}"
puts "   Specialty: #{provider_profile.specialty}"
puts "   Services: #{provider_profile.services.count}"
puts "   Availabilities: #{provider_profile.availabilities.count}"
puts ""
puts "📊 New Profile Attributes Demonstrated:"
puts "   Areas of Expertise: #{provider_profile.areas_of_expertise_array.count} areas"
puts "   Industries Served: #{provider_profile.industries_served_array.count} industries"
puts "   Session Formats: #{provider_profile.session_formats_array.count} formats"
puts "   Philosophy: #{provider_profile.philosophy.present? ? 'Yes' : 'No'}"
puts "   Languages: #{provider_profile.languages_array.join(', ')}"
