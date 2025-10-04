class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :duration_minutes
      t.decimal :price
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
