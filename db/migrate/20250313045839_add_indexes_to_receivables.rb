class AddIndexesToReceivables < ActiveRecord::Migration[7.2]
  def change
    add_index :receivables, [:schedule_date, :status]
    add_index :receivables, :payment_transaction_id
  end
end
