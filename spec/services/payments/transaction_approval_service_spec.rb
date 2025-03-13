require 'rails_helper'

RSpec.describe Payments::TransactionApprovalService, type: :service do
  let(:payment_transaction) { instance_double('PaymentTransaction', installment: 2) }
  subject(:service) { described_class.new(payment_transaction) }

  describe '#is_rejected' do
    context 'quando o número de parcelas (installment) é ímpar' do
      it 'retorna true' do
        allow(payment_transaction).to receive(:installment).and_return(3)

        expect(service.is_rejected(payment_transaction)).to eq(true)
      end
    end

    context 'quando o número de parcelas (installment) é par' do
      it 'retorna false' do
        allow(payment_transaction).to receive(:installment).and_return(2)
        
        expect(service.is_rejected(payment_transaction)).to eq(false)
      end
    end
  end
end
