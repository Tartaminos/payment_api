require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!  # ou inline!, conforme sua necessidade

RSpec.describe ReceivableGeneratorWorker, type: :worker do
  # Se deseja verificar a fila padrão
  it { is_expected.to be_processed_in :default }

  describe 'Job enqueuing' do
    it 'enfileira o job com os argumentos corretos' do
      expect {
        described_class.perform_async(123, 50.0)
      }.to change(described_class.jobs, :size).by(1)
    end
  end

  describe '#perform' do
    let(:transaction_id) { 123 }
    let(:amount_per_receivable) { 50.0 }

    it 'chama Receivables::GenerateService para criar receivables' do
      generate_service = instance_double('Receivables::GenerateService')
      allow(Receivables::GenerateService).to receive(:new).and_return(generate_service)
      allow(generate_service).to receive(:generate_receivable)

      # Executa o perform diretamente
      described_class.new.perform(transaction_id, amount_per_receivable)

      expect(generate_service).to have_received(:generate_receivable).with(transaction_id, amount_per_receivable)
    end
  end
end
