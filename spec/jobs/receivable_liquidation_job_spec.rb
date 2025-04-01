require 'rails_helper'

RSpec.describe ReceivableLiquidationJob, type: :job do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'usa a fila correta' do
    expect(described_class.queue_name).to eq('receivable_liquidation')
  end

  describe 'Job enqueuing' do
    it 'enfileira o job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue('receivable_liquidation')
    end
  end

  describe '#perform' do
    it 'chama o liquidation_service e executa liquidate com a data atual' do
      liquidation_service = instance_double('Receivables::LiquidationService')
      allow(Receivables::LiquidationService).to receive(:new).and_return(liquidation_service)
      allow(liquidation_service).to receive(:liquidate)

      described_class.perform_now

      expect(liquidation_service).to have_received(:liquidate).with(Date.current)
    end
  end
end
