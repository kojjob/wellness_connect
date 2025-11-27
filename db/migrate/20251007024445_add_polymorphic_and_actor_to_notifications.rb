class AddPolymorphicAndActorToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_reference :notifications, :actor, null: true, foreign_key: { to_table: :users }
    add_reference :notifications, :notifiable, polymorphic: true, null: true
    add_column :notifications, :delivered_at, :datetime

    # Add composite index for performance (user + read status)
    add_index :notifications, [ :user_id, :read_at ], name: 'index_notifications_on_user_and_read_status'
    # Note: add_reference already creates index for notifiable (polymorphic)
  end
end
