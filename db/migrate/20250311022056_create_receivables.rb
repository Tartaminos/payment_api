class CreateReceivables < ActiveRecord::Migration[7.2]
  def change
    create_table :receivables do |t|
      t.references :payment_transaction, null: false, foreign_key: { to_table: :payment_transactions }
      t.integer :installment
      t.date :schedule_date
      t.date :liquidation_date
      t.string :status
      t.decimal :amount_to_settle
      t.decimal :amount_settled

      t.timestamps
    end
  end
end
