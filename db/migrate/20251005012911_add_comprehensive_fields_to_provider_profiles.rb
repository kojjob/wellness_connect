class AddComprehensiveFieldsToProviderProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :provider_profiles, :areas_of_expertise, :text
    add_column :provider_profiles, :treatment_modalities, :text
    add_column :provider_profiles, :philosophy, :text
    add_column :provider_profiles, :session_formats, :text
    add_column :provider_profiles, :industries_served, :text
  end
end
