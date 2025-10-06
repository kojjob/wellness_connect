class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :patient, null: false, foreign_key: false
      t.references :provider, null: false, foreign_key: false
      t.references :appointment, null: true, foreign_key: false, index: false
      t.datetime :last_message_at
      t.integer :patient_unread_count, default: 0, null: false
      t.integer :provider_unread_count, default: 0, null: false
      t.boolean :archived_by_patient, default: false, null: false
      t.boolean :archived_by_provider, default: false, null: false

      t.timestamps
    end

    # Add foreign keys with on_delete options explicitly
    add_foreign_key :conversations, :users, column: :patient_id, on_delete: :cascade
    add_foreign_key :conversations, :users, column: :provider_id, on_delete: :cascade
    add_foreign_key :conversations, :appointments, on_delete: :nullify

    # Indexes for performance
    add_index :conversations, [ :patient_id, :last_message_at ],
              order: { last_message_at: :desc },
              comment: "Find patient's conversations sorted by recent activity"

    add_index :conversations, [ :provider_id, :last_message_at ],
              order: { last_message_at: :desc },
              comment: "Find provider's conversations sorted by recent activity"

    add_index :conversations, :appointment_id,
              unique: true,
              where: "appointment_id IS NOT NULL",
              comment: "Ensure one conversation per appointment"

    add_index :conversations, [ :patient_id, :provider_id ],
              comment: "Find conversation between two users"

    # Check constraint: patient and provider must be different users
    add_check_constraint :conversations,
                         "patient_id != provider_id",
                         name: "conversations_different_participants"

    # Check constraint: unread counts must be non-negative
    add_check_constraint :conversations,
                         "patient_unread_count >= 0",
                         name: "conversations_patient_unread_non_negative"

    add_check_constraint :conversations,
                         "provider_unread_count >= 0",
                         name: "conversations_provider_unread_non_negative"
  end
end
