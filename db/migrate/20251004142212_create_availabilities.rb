class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :is_booked, default: false

      t.timestamps
    end
  end
end
