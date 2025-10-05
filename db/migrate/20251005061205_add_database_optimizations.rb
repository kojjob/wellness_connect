class AddDatabaseOptimizations < ActiveRecord::Migration[8.1]
  def change
    # ====================
    # INDEXES FOR QUERY OPTIMIZATION
    # ====================

    # Appointments table - frequently queried columns
    add_index :appointments, :status, comment: "Filter appointments by status (scheduled, completed, cancelled)"
    add_index :appointments, :start_time, comment: "Query appointments by date/time range"

    # Composite indexes for common query patterns
    add_index :appointments, [:patient_id, :status], comment: "Find patient appointments by status"
    add_index :appointments, [:provider_id, :status], comment: "Find provider appointments by status"
    add_index :appointments, [:provider_id, :start_time], comment: "Find provider's upcoming appointments"

    # Availabilities table - critical for booking flow
    add_index :availabilities, :is_booked, comment: "Find available booking slots"
    add_index :availabilities, :start_time, comment: "Filter availability by date/time"
    add_index :availabilities, [:provider_profile_id, :is_booked, :start_time],
              name: "index_availabilities_on_provider_availability",
              comment: "Optimized query for finding provider's available slots"

    # Services table - filter active services
    add_index :services, :is_active, comment: "Show only active services to clients"
    add_index :services, [:provider_profile_id, :is_active], comment: "Get provider's active services"

    # Provider profiles - search and filter
    add_index :provider_profiles, :specialty, comment: "Filter providers by specialty"

    # Users table - role-based queries
    add_index :users, :role, comment: "Filter users by role (patient, provider, admin)"

    # Payments table - status queries
    add_index :payments, :status, comment: "Filter payments by status (pending, succeeded, failed)"
    add_index :payments, [:payer_id, :status], comment: "Find user's payments by status"

    # Notifications table - unread notifications
    add_index :notifications, :read_at, comment: "Find unread notifications (WHERE read_at IS NULL)"
    add_index :notifications, :notification_type, comment: "Filter notifications by type"
    add_index :notifications, [:user_id, :read_at], comment: "Find user's unread notifications"

    # ====================
    # UNIQUE CONSTRAINTS
    # ====================

    # Ensure one-to-one relationships at database level
    add_index :consultation_notes, :appointment_id, unique: true,
              name: "index_consultation_notes_unique_appointment",
              comment: "One note per appointment"

    add_index :patient_profiles, :user_id, unique: true,
              name: "index_patient_profiles_unique_user",
              comment: "One patient profile per user"

    add_index :provider_profiles, :user_id, unique: true,
              name: "index_provider_profiles_unique_user",
              comment: "One provider profile per user"

    # ====================
    # CHECK CONSTRAINTS (with data cleanup)
    # ====================

    # Clean up invalid data before adding constraints
    reversible do |dir|
      dir.up do
        # Fix appointments where end_time <= start_time (set end_time = start_time + 1 hour)
        execute <<-SQL
          UPDATE appointments
          SET end_time = start_time + INTERVAL '1 hour'
          WHERE end_time IS NOT NULL AND start_time IS NOT NULL AND end_time <= start_time;
        SQL

        # Fix availabilities where end_time <= start_time
        execute <<-SQL
          UPDATE availabilities
          SET end_time = start_time + INTERVAL '1 hour'
          WHERE end_time IS NOT NULL AND start_time IS NOT NULL AND end_time <= start_time;
        SQL

        # Fix services with invalid price or duration
        execute <<-SQL
          UPDATE services
          SET price = 0
          WHERE price < 0;
        SQL

        execute <<-SQL
          UPDATE services
          SET duration_minutes = 30
          WHERE duration_minutes IS NOT NULL AND duration_minutes <= 0;
        SQL

        # Fix provider_profiles with invalid consultation_rate
        execute <<-SQL
          UPDATE provider_profiles
          SET consultation_rate = 50
          WHERE consultation_rate IS NOT NULL AND consultation_rate <= 0;
        SQL

        # Fix payments with invalid amount
        execute <<-SQL
          UPDATE payments
          SET amount = 0.01
          WHERE amount IS NOT NULL AND amount <= 0;
        SQL
      end
    end

    # Now add check constraints safely
    add_check_constraint :appointments, "end_time > start_time",
                        name: "appointments_end_after_start"

    add_check_constraint :availabilities, "end_time > start_time",
                        name: "availabilities_end_after_start"

    add_check_constraint :services, "price >= 0",
                        name: "services_price_positive"
    add_check_constraint :services, "duration_minutes > 0",
                        name: "services_duration_positive"

    add_check_constraint :provider_profiles, "consultation_rate > 0",
                        name: "provider_profiles_rate_positive"

    add_check_constraint :payments, "amount > 0",
                        name: "payments_amount_positive"
  end
end
