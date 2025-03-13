class ReceivableLiquidationWorker
    include Sidekiq::Worker
  
    def perform
      liquidation_service = Receivables::LiquidationService.new()
      liquidation_service.liquidate(Date.current)      
    end
  end