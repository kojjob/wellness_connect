class AddEnhancedFieldsToProviderProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :provider_profiles, :years_of_experience, :integer
    add_column :provider_profiles, :education, :text
    add_column :provider_profiles, :certifications, :text
    add_column :provider_profiles, :languages, :text
    add_column :provider_profiles, :phone, :string
    add_column :provider_profiles, :office_address, :text
    add_column :provider_profiles, :website, :string
    add_column :provider_profiles, :linkedin_url, :string
    add_column :provider_profiles, :twitter_url, :string
    add_column :provider_profiles, :facebook_url, :string
    add_column :provider_profiles, :instagram_url, :string
    add_column :provider_profiles, :average_rating, :decimal
    add_column :provider_profiles, :total_reviews, :integer
  end
end
