module Payments
    class TransactionApprovalService

        def initialize(payment_transaction)
            @payment_transaction = payment_transaction
        end

        def is_rejected(payment_transaction)
            payment_transaction.installment.odd?
        end
    end
end