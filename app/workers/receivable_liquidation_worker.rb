class ReceivableLiquidationWorker
    include Sidekiq::Worker

    sidekiq_options queue: :receivable_liquidation
  
    def perform
      liquidation_service = Receivables::LiquidationService.new()
      liquidation_service.liquidate(Date.current)      
    end
  end