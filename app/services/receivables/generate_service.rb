module Receivables
    class GenerateService
        def initialize()
        end

        def generate_receivable(transaction_id, amount_per_receivable)
            transaction_service = Payments::PaymentTransactionService.new()
            transaction = transaction_service.load_transaction_by_id(transaction_id)
    
            receivable_service = Receivables::ReceivablesService.new()
            receivable_service.create_receivable(transaction, amount_per_receivable)
        end

    end
end