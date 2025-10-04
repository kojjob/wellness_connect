class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :payer, null: false, foreign_key: { to_table: :users }
      t.references :appointment, null: true, foreign_key: true
      t.decimal :amount
      t.string :currency, default: 'USD'
      t.integer :status
      t.string :stripe_payment_intent_id
      t.datetime :paid_at

      t.timestamps
    end

    add_index :payments, :stripe_payment_intent_id
  end
end
