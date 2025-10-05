class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :provider_profile, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end

    # Add check constraint for rating (1-5 stars)
    add_check_constraint :reviews, "rating >= 1 AND rating <= 5", name: "rating_range_check"

    # Add indexes for better query performance
    add_index :reviews, [ :provider_profile_id, :created_at ], name: "index_reviews_on_provider_and_date"
    add_index :reviews, :reviewer_id
  end
end
