require 'rails_helper'

RSpec.describe Gateways::PaymentGatewayService, type: :service do
  let(:payment_transaction) { instance_double('PaymentTransaction', id: 1, installment: 2, status: 'pendente', amount: 100.0) }
  let(:service) { described_class.new(payment_transaction) }

  describe '#process_transaction' do
    let(:transaction_approval_service) { instance_double('Payments::TransactionApprovalService') }

    before do
      allow(Payments::TransactionApprovalService).to receive(:new).with(payment_transaction).and_return(transaction_approval_service)
    end

    context 'quando a trasação é rejeitada' do
      it 'chama o reject e atualiza o status' do
        allow(transaction_approval_service).to receive(:is_rejected).with(payment_transaction).and_return(true)

        expect(service).to receive(:reject_transaction).and_call_original
        allow(payment_transaction).to receive(:update!).with({ status: 'reprovado' })

        result = service.process_transaction(payment_transaction)

        expect(result[:success]).to eq(false)
        expect(result[:message]).to match(/Transação reprovada: número de parcelas ímpar/)
      end
    end

    context 'quando a transação não é rejeitada' do
      it 'chama o approve e atualiza o status' do
        allow(transaction_approval_service).to receive(:is_rejected).with(payment_transaction).and_return(false)

        expect(service).to receive(:approve_transaction).and_call_original
        allow(payment_transaction).to receive(:update!).with({ status: 'aprovado' })

        allow(service).to receive(:retention_calc).and_return(95.0)
        allow(service).to receive(:amount_per_receivable_calc).and_return(47.5)
        allow(service).to receive(:schedule_receivable)

        result = service.process_transaction(payment_transaction)

        expect(result[:success]).to eq(true)
        expect(result[:message]).to match(/Transação aprovada e em processamento./)
      end
    end
  end

  describe '#approve_transaction' do
    before do
      allow(payment_transaction).to receive(:update!).with({ status: 'aprovado' })
      allow(service).to receive(:retention_calc).and_return(95.0)
      allow(service).to receive(:amount_per_receivable_calc).and_return(47.5)
      allow(service).to receive(:schedule_receivable)
    end

    it 'atualiza o status para aprovado, faz o cálculo de retenção e agenda os receivables' do
      result = service.approve_transaction

      expect(result[:success]).to eq(true)
      expect(result[:message]).to match(/Transação aprovada e em processamento/)
    end
  end

  describe '#reject_transaction' do
    it 'atualiza o status para reprovado e retorna a mensagem de rejeição' do
      allow(payment_transaction).to receive(:update!).with({ status: 'reprovado' })

      result = service.reject_transaction

      expect(result[:success]).to eq(false)
      expect(result[:message]).to match(/Transação reprovada/)
    end
  end

  describe '#retention_calc' do
    it 'chama o Fees::InstallmentFeesService para calcular a taxa e aplica a retenção' do
      fee_service = instance_double('Fees::InstallmentFeesService')
      allow(Fees::InstallmentFeesService).to receive(:new).with(payment_transaction.installment).and_return(fee_service)
      allow(fee_service).to receive(:installment_fee_percentage).with(payment_transaction.installment).and_return(2.5)
      allow(fee_service).to receive(:retention_calculation).with(payment_transaction, 2.5).and_return(97.5)

      result = service.retention_calc(payment_transaction)
      expect(result).to eq(97.5)
    end
  end

  describe '#amount_per_receivable_calc' do
    it 'divide o valor repassado pela quantidade de parcelas' do
      result = service.amount_per_receivable_calc(95.0, payment_transaction)
      expect(result).to eq(95.0 / payment_transaction.installment)
    end
  end

  describe '#schedule_receivable' do
    it 'chama o Receivables::ReceivableSchedulerService para agendar os receivables' do
      scheduler_service = instance_double('Receivables::ReceivableSchedulerService')
      allow(Receivables::ReceivableSchedulerService).to receive(:new).and_return(scheduler_service)
      allow(scheduler_service).to receive(:schedule)

      service.schedule_receivable(50.0)

      expect(scheduler_service).to have_received(:schedule).with(payment_transaction, 50.0)
    end
  end
end