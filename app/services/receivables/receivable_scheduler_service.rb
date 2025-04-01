module Receivables
    class ReceivableSchedulerService
        def initialize()
        end
    
        def schedule(transaction, amount_per_receivable)
            ReceivableGeneratorJob.perform_later(transaction.id, amount_per_receivable.to_f)
        end
    end
end