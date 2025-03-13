class PaymentTransaction < ApplicationRecord
    has_many :receivables, dependent: :destroy
    validates :amount, presence: true
    validates :installment, presence: true

    def self.load_transaction_by_id(transaction_id)
        PaymentTransaction.find_by_id(transaction_id)
    end

    def self.load_transaction_by_date_range(start_date, end_date)
        PaymentTransaction.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

end
