class AddIndexesToPaymentsTransactions < ActiveRecord::Migration[7.2]
  def change
    add_index :payment_transactions, :created_at
    add_index :payment_transactions, :payment_method
    add_index :payment_transactions, :status
                                      where: "status = aprovado"
  end
end
