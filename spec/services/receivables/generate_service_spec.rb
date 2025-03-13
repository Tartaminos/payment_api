require 'rails_helper'

RSpec.describe Receivables::GenerateService, type: :service do
  describe '#generate_receivable' do
    let(:transaction_id) { 123 }
    let(:amount_per_receivable) { 100.0 }
    let(:transaction) { instance_double('PaymentTransaction') }

    it 'carrega a transação e chama create_receivable no ReceivablesService' do
      # Mock do PaymentTransactionService
      transaction_service = instance_double(Payments::PaymentTransactionService)
      allow(Payments::PaymentTransactionService).to receive(:new).and_return(transaction_service)
      allow(transaction_service).to receive(:load_transaction_by_id).with(transaction_id).and_return(transaction)

      # Mock do ReceivablesService
      receivable_service = instance_double(Receivables::ReceivablesService)
      allow(Receivables::ReceivablesService).to receive(:new).and_return(receivable_service)
      allow(receivable_service).to receive(:create_receivable).with(transaction, amount_per_receivable)

      # Executa o serviço
      service = described_class.new
      service.generate_receivable(transaction_id, amount_per_receivable)

      # Verifica se os métodos esperados foram chamados
      expect(transaction_service).to have_received(:load_transaction_by_id).with(transaction_id)
      expect(receivable_service).to have_received(:create_receivable).with(transaction, amount_per_receivable)
    end
  end
end