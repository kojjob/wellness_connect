class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :email
      t.string :source
      t.string :utm_campaign
      t.string :utm_source
      t.string :utm_medium
      t.boolean :subscribed

      t.timestamps
    end
  end
end
