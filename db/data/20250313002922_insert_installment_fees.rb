# frozen_string_literal: true

class InsertInstallmentFees < ActiveRecord::Migration[7.2]
  def up
    (1..12).each do |i|
      InstallmentFee.create!(
        installments: i,
        fee_percentage: (0.99 * i)
      )
    end
  end

  def down
    InstallmentFee.delete_all
  end
end
