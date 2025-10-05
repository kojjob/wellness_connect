class AddStatusFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :suspended_at, :datetime
    add_column :users, :blocked_at, :datetime
    add_column :users, :status_reason, :text
  end
end
