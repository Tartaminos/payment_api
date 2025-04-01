class ReceivableLiquidationJob < ApplicationJob
    queue_as :receivable_liquidation
  
    def perform
      liquidation_service = Receivables::LiquidationService.new
      liquidation_service.liquidate(Date.current)
    end
  end
  