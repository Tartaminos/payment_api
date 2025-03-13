module Receivables
    class LiquidationService
        def initialize()
        end

        def liquidate(date)
            receivable_service = Receivables::ReceivablesService.new()
            receivable_to_liquidate = receivable_service.load_pending_today_receivables()

            receivable_service.liquidate_receivable(receivable_to_liquidate, date)
        end
    end
end