require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe ReceivableLiquidationWorker, type: :worker do
  it { is_expected.to be_processed_in :receivable_liquidation }

  describe 'Job enqueuing' do
    it 'enfileira o job sem argumentos' do
      expect {
        described_class.perform_async
      }.to change(described_class.jobs, :size).by(1)
    end
  end

  describe '#perform' do
    it 'chama o liquidation_service e executa liquidate com a data atual' do
      liquidation_service = instance_double('Receivables::LiquidationService')
      allow(Receivables::LiquidationService).to receive(:new).and_return(liquidation_service)
      allow(liquidation_service).to receive(:liquidate)

      described_class.new.perform

      expect(liquidation_service).to have_received(:liquidate).with(Date.current)
    end
  end
end