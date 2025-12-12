class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Add index on provider_profiles.average_rating for sorting and filtering
    # This is critical for the provider search/browse page
    add_index :provider_profiles, :average_rating,
              name: 'index_provider_profiles_on_average_rating',
              comment: 'Optimize provider sorting by rating'

    # Add composite index for common search pattern: rating + specialty
    # Many searches filter by specialty AND sort by rating
    add_index :provider_profiles, [ :average_rating, :specialty ],
              name: 'index_provider_profiles_on_rating_and_specialty',
              comment: 'Optimize searches filtering by specialty and sorting by rating'

    # Add indexes on users first_name and last_name for search queries
    # Used in provider search and admin user management
    add_index :users, :first_name,
              name: 'index_users_on_first_name',
              comment: 'Optimize user search by first name'

    add_index :users, :last_name,
              name: 'index_users_on_last_name',
              comment: 'Optimize user search by last name'

    # Add composite index for full name searches
    add_index :users, [ :first_name, :last_name ],
              name: 'index_users_on_first_and_last_name',
              comment: 'Optimize user search by full name'
  end
end
