module Receivables
    class ReceivableSchedulerService
        def initialize()
        end
    
        def schedule(transaction, amount_per_receivable)
            ReceivableGeneratorWorker.perform_async(transaction.id, amount_per_receivable.to_f)
        end
    end
end