require 'rails_helper'

RSpec.describe Fees::InstallmentFeesService, type: :service do
  let(:installment) { 3 }
  let(:service) { described_class.new(installment) }

  describe '#installment_fee_percentage' do
    it 'chama o método da model InstallmentFee e retorna o valor como float' do
      allow(InstallmentFee).to receive(:installment_fee_percentage).with(installment).and_return(2.5)

      result = service.installment_fee_percentage(installment)
      expect(result).to eq(2.5)
    end
  end

  describe '#retention_calculation' do
    let(:payment_transaction) { instance_double('PaymentTransaction', amount: 100.0) }
    let(:fee_percentage) { 2.5 }

    it 'calcula o valor a reter e retorna a quantia líquida correta' do
      # (fee_percentage / 100) = 2.5 / 100 = 0.025
      # total_retention = 100.0 * 0.025 = 2.5
      # valor liquido = 100.0 - 2.5 = 97.5
      result = service.retention_calculation(payment_transaction, fee_percentage)
      expect(result).to eq(97.5)
    end
  end
end