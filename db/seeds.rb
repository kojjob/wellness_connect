# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Seeding database..."

# Create Super Admin User
puts "Creating Super Admin user..."
super_admin = User.find_or_create_by!(email: "superadmin@wellnessconnect.com") do |user|
  user.first_name = "Super"
  user.last_name = "Admin"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :super_admin
  user.time_zone = "UTC"
end
puts "✅ Super Admin created: #{super_admin.email}"

# Create Regular Admin User
puts "Creating Admin user..."
admin = User.find_or_create_by!(email: "admin@wellnessconnect.com") do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
  user.time_zone = "UTC"
end
puts "✅ Admin created: #{admin.email}"

# Create Sample Provider User
puts "Creating Provider user..."
provider = User.find_or_create_by!(email: "provider@wellnessconnect.com") do |user|
  user.first_name = "Dr. Sarah"
  user.last_name = "Johnson"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :provider
  user.time_zone = "America/New_York"
end

# Create provider profile if it doesn't exist
if provider.provider_profile.nil?
  provider.create_provider_profile!(
    specialty: "Mental Health Counseling",
    bio: "Licensed therapist with 10+ years of experience in cognitive behavioral therapy and mindfulness-based interventions.",
    credentials: "Licensed Clinical Social Worker (LCSW), Certified CBT Practitioner",
    consultation_rate: 150.00,
    years_of_experience: 10
  )
end
puts "✅ Provider created: #{provider.email}"

# Create Sample Patient User
puts "Creating Patient user..."
patient = User.find_or_create_by!(email: "patient@wellnessconnect.com") do |user|
  user.first_name = "John"
  user.last_name = "Doe"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :patient
  user.time_zone = "America/Los_Angeles"
end

# Create patient profile if it doesn't exist
if patient.patient_profile.nil?
  patient.create_patient_profile!(
    health_goals: "Reduce stress and improve work-life balance",
    date_of_birth: 30.years.ago.to_date
  )
end
puts "✅ Patient created: #{patient.email}"

puts "\n🎉 Seeding completed successfully!"
puts "\n📝 Login Credentials:"
puts "Super Admin: superadmin@wellnessconnect.com / password123"
puts "Admin: admin@wellnessconnect.com / password123"
puts "Provider: provider@wellnessconnect.com / password123"
puts "Patient: patient@wellnessconnect.com / password123"
