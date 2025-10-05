class AddAvailabilityToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_reference :appointments, :availability, null: true, foreign_key: true
  end
end
