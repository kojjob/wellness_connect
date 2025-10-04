class CreatePatientProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :patient_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date_of_birth
      t.text :health_goals
      t.text :medical_history_summary

      t.timestamps
    end
  end
end
