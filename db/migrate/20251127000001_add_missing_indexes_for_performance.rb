class AddMissingIndexesForPerformance < ActiveRecord::Migration[8.0]
  def change
    # Index for appointments.service_id to speed up N+1 queries when loading services
    add_index :appointments, :service_id, if_not_exists: true

    # Index for notifications.created_at for sorting unread notifications by recency
    add_index :notifications, :created_at, if_not_exists: true

    # Index for payments.created_at for date range queries in PaymentsController
    add_index :payments, :created_at, if_not_exists: true

    # Composite index for payments status filtering with date sorting
    add_index :payments, [ :status, :created_at ], name: "index_payments_on_status_and_created_at", if_not_exists: true
  end
end
