class AddStatusToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :suspended_at, :datetime
    add_column :users, :blocked_at, :datetime
    add_column :users, :status_reason, :text

    add_index :users, :suspended_at
    add_index :users, :blocked_at
  end
end
