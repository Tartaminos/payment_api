module Payments
    class PaymentTransactionService
        def initialize(params = {})
          @params = params
        end

        def create_transaction(params)
            PaymentTransaction.new(params)
        end

        def load_transaction_by_id(transaction_id)
            PaymentTransaction.load_transaction_by_id(transaction_id)
        end

        def load_transaction_by_date_range(start_date, end_date)
            PaymentTransaction.load_transaction_by_date_range(start_date, end_date)
        end

    end
end