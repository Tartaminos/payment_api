class CreatePaymentTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_transactions do |t|
      t.decimal :amount
      t.integer :installment
      t.string :payment_method
      t.string :status

      t.timestamps
    end
  end
end
