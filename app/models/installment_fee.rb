class InstallmentFee < ApplicationRecord
    validates :installments, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 12 }
    validates :fee_percentage, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def self.installment_fee_percentage(installment)
        InstallmentFee.find_by_installments(installment).fee_percentage
    end

end
