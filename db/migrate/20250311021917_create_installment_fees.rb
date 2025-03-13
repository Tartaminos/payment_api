class CreateInstallmentFees < ActiveRecord::Migration[7.2]
  def change
    create_table :installment_fees do |t|
      t.integer :installments
      t.decimal :fee_percentage

      t.timestamps
    end
  end
end
