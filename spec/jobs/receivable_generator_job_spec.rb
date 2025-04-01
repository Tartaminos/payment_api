require 'rails_helper'

RSpec.describe ReceivableGeneratorJob, type: :job do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'usa a fila correta' do
    expect(described_class.queue_name).to eq('receivable_generation')
  end

  describe 'Job enqueuing' do
    it 'enfileira o job com os argumentos corretos' do
      expect {
        described_class.perform_later(123, 50.0)
      }.to have_enqueued_job(described_class).with(123, 50.0).on_queue('receivable_generation')
    end
  end

  describe '#perform' do
    let(:transaction_id) { 123 }
    let(:amount_per_receivable) { 50.0 }

    it 'chama Receivables::GenerateService para criar receivables' do
      generate_service = instance_double('Receivables::GenerateService')
      allow(Receivables::GenerateService).to receive(:new).and_return(generate_service)
      allow(generate_service).to receive(:generate_receivable)

      described_class.perform_now(transaction_id, amount_per_receivable)

      expect(generate_service).to have_received(:generate_receivable).with(transaction_id, amount_per_receivable)
    end
  end
end
