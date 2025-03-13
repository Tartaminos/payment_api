class ReceivableGeneratorWorker
    include Sidekiq::Worker

    def perform(transaction_id, amount_per_receivable)
        generate_service = Receivables::GenerateService.new()
        generate_service.generate_receivable(transaction_id, amount_per_receivable)
    end

end