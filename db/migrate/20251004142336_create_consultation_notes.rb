class CreateConsultationNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :consultation_notes do |t|
      t.references :appointment, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
