require 'rails_helper'

RSpec.describe Receivables::ReceivableSchedulerService, type: :service do
  describe '#schedule' do
    let(:transaction) { instance_double('PaymentTransaction', id: 1) }
    let(:amount_per_receivable) { 50.0 }
    subject(:service) { described_class.new }

    it 'envia para a fila de execução do ReceivableGeneratorWorker com os argumentos corretos' do
      expect(ReceivableGeneratorWorker).to receive(:perform_async).with(transaction.id, amount_per_receivable.to_f)
      service.schedule(transaction, amount_per_receivable)
    end
  end
end