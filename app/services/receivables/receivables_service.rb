module Receivables
    class ReceivablesService
        def initialize()
        end
    
        def load_approved_receivables()
            Receivable.approved
        end

        def load_pending_today_receivables()
            Receivable.pending_today
        end

        def liquidate_receivable(receivable_to_liquidate, date)
            Receivable.liquidate_receivable(receivable_to_liquidate, date)
        end

        def create_receivable(transaction, amount_per_receivable)
            Receivable.create_receivable(transaction, amount_per_receivable)
        end

        def load_all_receivables()
            Receivable.all_receivables
        end

      end
end