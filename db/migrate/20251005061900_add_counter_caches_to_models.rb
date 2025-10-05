class AddCounterCachesToModels < ActiveRecord::Migration[8.1]
  def change
    # Add counter cache columns
    add_column :provider_profiles, :services_count, :integer, default: 0, null: false
    add_column :provider_profiles, :availabilities_count, :integer, default: 0, null: false
    add_column :services, :appointments_count, :integer, default: 0, null: false
    add_column :users, :appointments_as_patient_count, :integer, default: 0, null: false
    add_column :users, :appointments_as_provider_count, :integer, default: 0, null: false

    # Backfill existing counters
    reversible do |dir|
      dir.up do
        # ProviderProfile services counter
        execute <<-SQL
          UPDATE provider_profiles
          SET services_count = (
            SELECT COUNT(*) FROM services WHERE services.provider_profile_id = provider_profiles.id
          );
        SQL

        # ProviderProfile availabilities counter
        execute <<-SQL
          UPDATE provider_profiles
          SET availabilities_count = (
            SELECT COUNT(*) FROM availabilities WHERE availabilities.provider_profile_id = provider_profiles.id
          );
        SQL

        # Service appointments counter
        execute <<-SQL
          UPDATE services
          SET appointments_count = (
            SELECT COUNT(*) FROM appointments WHERE appointments.service_id = services.id
          );
        SQL

        # User appointments as patient counter
        execute <<-SQL
          UPDATE users
          SET appointments_as_patient_count = (
            SELECT COUNT(*) FROM appointments WHERE appointments.patient_id = users.id
          );
        SQL

        # User appointments as provider counter
        execute <<-SQL
          UPDATE users
          SET appointments_as_provider_count = (
            SELECT COUNT(*) FROM appointments WHERE appointments.provider_id = users.id
          );
        SQL
      end
    end

    # Add indexes on counter cache columns for sorting/filtering
    add_index :provider_profiles, :services_count
    add_index :provider_profiles, :availabilities_count
    add_index :services, :appointments_count
    add_index :users, :appointments_as_patient_count
    add_index :users, :appointments_as_provider_count
  end
end
