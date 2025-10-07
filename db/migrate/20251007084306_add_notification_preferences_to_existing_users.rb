class AddNotificationPreferencesToExistingUsers < ActiveRecord::Migration[8.1]
  def up
    # Create notification preferences for all existing users who don't have one
    User.find_each do |user|
      next if NotificationPreference.exists?(user_id: user.id)

      NotificationPreference.create!(
        user: user,
        email_appointments: true,
        email_messages: true,
        email_payments: true,
        email_system: true,
        in_app_appointments: true,
        in_app_messages: true,
        in_app_payments: true,
        in_app_system: true
      )
    end
  end

  def down
    # This is a data migration - no need to reverse
    # Preferences will be deleted when users are deleted (dependent: :destroy)
  end
end
