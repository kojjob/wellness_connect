class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }, index: false
      t.text :content # Encrypted via Rails encrypts in model
      t.integer :message_type, default: 0, null: false
      t.datetime :read_at
      t.datetime :edited_at

      t.timestamps
    end

    # Indexes for performance
    add_index :messages, [:conversation_id, :created_at],
              order: { created_at: :asc },
              comment: "Find conversation messages sorted chronologically"

    add_index :messages, :sender_id,
              comment: "Find messages by sender"

    add_index :messages, :read_at,
              where: "read_at IS NULL",
              comment: "Find unread messages"

    add_index :messages, :message_type,
              comment: "Filter messages by type"

    # Custom validation at model level handles:
    # - Content OR attachment required (at least one must be present)
    # - Sender must be a participant in the conversation
  end
end
