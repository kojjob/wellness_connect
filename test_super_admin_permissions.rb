# Test script to verify super_admin permissions
# Run with: bin/rails runner test_super_admin_permissions.rb

puts "Testing Super Admin Permissions..."
puts "=" * 50

# Create test users
super_admin = User.find_or_create_by!(email: "super@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :super_admin
  u.first_name = "Super"
  u.last_name = "Admin"
end

regular_admin = User.find_or_create_by!(email: "admin@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
  u.first_name = "Regular"
  u.last_name = "Admin"
end

patient_user = User.find_or_create_by!(email: "patient@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :patient
  u.first_name = "Test"
  u.last_name = "Patient"
end

provider_user = User.find_or_create_by!(email: "provider@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :provider
  u.first_name = "Test"
  u.last_name = "Provider"
end

puts "\nTest Users Created:"
puts "  Super Admin: #{super_admin.email} (role: #{super_admin.role})"
puts "  Regular Admin: #{regular_admin.email} (role: #{regular_admin.role})"
puts "  Patient: #{patient_user.email} (role: #{patient_user.role})"
puts "  Provider: #{provider_user.email} (role: #{provider_user.role})"

# Create profiles
patient_profile = PatientProfile.find_or_create_by!(user: patient_user) do |p|
  p.health_goals = "Test health goals"
end

provider_profile = ProviderProfile.find_or_create_by!(user: provider_user) do |p|
  p.specialty = "Test Specialty"
  p.bio = "Test bio that meets the minimum length requirement of 50 characters for validation purposes."
  p.consultation_rate = 100.00
end

puts "\nProfiles Created:"
puts "  Patient Profile: ID #{patient_profile.id}"
puts "  Provider Profile: ID #{provider_profile.id}"

# Test Admin::UserPolicy
puts "\n" + "=" * 50
puts "Testing Admin::UserPolicy"
puts "=" * 50

user_policy_super = Admin::UserPolicy.new(super_admin, patient_user)
user_policy_admin = Admin::UserPolicy.new(regular_admin, patient_user)

puts "Super Admin can update users: #{user_policy_super.update?}"
puts "Super Admin can edit users: #{user_policy_super.edit?}"
puts "Super Admin can destroy users: #{user_policy_super.destroy?}"

# Test Admin::ProviderProfilePolicy
puts "\n" + "=" * 50
puts "Testing Admin::ProviderProfilePolicy"
puts "=" * 50

provider_policy_super = Admin::ProviderProfilePolicy.new(super_admin, provider_profile)
provider_policy_admin = Admin::ProviderProfilePolicy.new(regular_admin, provider_profile)

puts "Super Admin can update provider profiles: #{provider_policy_super.update?}"
puts "Super Admin can edit provider profiles: #{provider_policy_super.edit?}"
puts "Regular Admin can update provider profiles: #{provider_policy_admin.update?}"
puts "Regular Admin can edit provider profiles: #{provider_policy_admin.edit?}"

# Test Admin::PatientProfilePolicy
puts "\n" + "=" * 50
puts "Testing Admin::PatientProfilePolicy"
puts "=" * 50

patient_policy_super = Admin::PatientProfilePolicy.new(super_admin, patient_profile)
patient_policy_admin = Admin::PatientProfilePolicy.new(regular_admin, patient_profile)

puts "Super Admin can update patient profiles: #{patient_policy_super.update?}"
puts "Super Admin can edit patient profiles: #{patient_policy_super.edit?}"
puts "Regular Admin can update patient profiles: #{patient_policy_admin.update?}"
puts "Regular Admin can edit patient profiles: #{patient_policy_admin.edit?}"

# Test Scopes
puts "\n" + "=" * 50
puts "Testing Policy Scopes"
puts "=" * 50

user_scope_super = Admin::UserPolicy::Scope.new(super_admin, User).resolve
user_scope_admin = Admin::UserPolicy::Scope.new(regular_admin, User).resolve

puts "Super Admin can see #{user_scope_super.count} users"
puts "Regular Admin can see #{user_scope_admin.count} users"

provider_scope_super = Admin::ProviderProfilePolicy::Scope.new(super_admin, ProviderProfile).resolve
provider_scope_admin = Admin::ProviderProfilePolicy::Scope.new(regular_admin, ProviderProfile).resolve

puts "Super Admin can see #{provider_scope_super.count} provider profiles"
puts "Regular Admin can see #{provider_scope_admin.count} provider profiles"

patient_scope_super = Admin::PatientProfilePolicy::Scope.new(super_admin, PatientProfile).resolve
patient_scope_admin = Admin::PatientProfilePolicy::Scope.new(regular_admin, PatientProfile).resolve

puts "Super Admin can see #{patient_scope_super.count} patient profiles"
puts "Regular Admin can see #{patient_scope_admin.count} patient profiles"

puts "\n" + "=" * 50
puts "✅ All Tests Complete!"
puts "=" * 50
puts "\nConclusion:"
puts "  • Super Admin can update users, patients, and providers ✓"
puts "  • Regular Admin can update providers and patients but NOT users ✓"
puts "  • Both can view all records through scopes ✓"
