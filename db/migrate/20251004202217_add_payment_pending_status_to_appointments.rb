class AddPaymentPendingStatusToAppointments < ActiveRecord::Migration[8.1]
  def change
    # Add payment_pending status (value: 5) to appointments enum
    # This status indicates appointment is created but payment hasn't been completed yet
    # Default status changed from 'scheduled' to 'payment_pending'
    # Existing appointments remain unaffected as they have status values 0-4

    # Note: No database changes required - enum value added to model only
    # Payment flow: payment_pending -> scheduled (on payment success)
    # Webhook will handle status transition when payment succeeds
  end
end
