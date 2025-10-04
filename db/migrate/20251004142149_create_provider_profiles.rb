class CreateProviderProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :specialty
      t.text :bio
      t.text :credentials
      t.decimal :consultation_rate

      t.timestamps
    end
  end
end
