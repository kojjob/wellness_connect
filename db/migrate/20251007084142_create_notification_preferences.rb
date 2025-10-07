class CreateNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      # Email notification preferences (default: true - opt-out model)
      t.boolean :email_appointments, default: true, null: false
      t.boolean :email_messages, default: true, null: false
      t.boolean :email_payments, default: true, null: false
      t.boolean :email_system, default: true, null: false

      # In-app notification preferences (default: true)
      t.boolean :in_app_appointments, default: true, null: false
      t.boolean :in_app_messages, default: true, null: false
      t.boolean :in_app_payments, default: true, null: false
      t.boolean :in_app_system, default: true, null: false

      t.timestamps
    end
  end
end
