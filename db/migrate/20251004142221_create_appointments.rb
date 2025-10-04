class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.references :service, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status
      t.text :cancellation_reason
      t.string :video_session_id

      t.timestamps
    end
  end
end
