class AddDownloadsCountToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :downloads_count, :integer, default: 0, null: false
  end
end
