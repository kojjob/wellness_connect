class AddSuperAdminRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    # Add comment explaining the super_admin role
    # super_admin (value: 3) - Has full system access including user creation/management
    # This is a higher privilege level than regular admin

    # Note: This migration doesn't change the database schema
    # The role enum values are defined in the User model
    # We're just documenting the addition of super_admin role (value: 3)
    # Existing roles: patient (0), provider (1), admin (2)
  end

  def down
    # No database changes to revert
    # Role enum changes are handled in the model
  end
end
