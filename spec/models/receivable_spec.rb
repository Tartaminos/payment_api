require 'rails_helper'

RSpec.describe Receivable, type: :model do
    describe 'associations' do
        it 'pertence a PaymentTransaction pela coluna payment_transaction_id' do

          payment_transaction = PaymentTransaction.create!(
            amount: 100.0,
            installment: 2,
            payment_method: 'visa',
            status: 'pendente'
          )
    
          receivable = described_class.create!(
            payment_transaction_id: payment_transaction.id,
            installment: 1,
            schedule_date: 1.day.from_now,
            status: 'pendente',
            amount_to_settle: 100.0,
            amount_settled: 0
          )
    
          expect(receivable.payment_transaction_id).to eq(payment_transaction.id)
          expect(receivable.payment_transaction).to eq(payment_transaction)
        end
      end

  describe 'scopes' do
    let!(:approved_transaction) { PaymentTransaction.create!(
      status: 'aprovado',
      amount: 100.0,
      installment: 3,
      payment_method: 'visa'
    ) }
    let!(:pending_transaction)  { PaymentTransaction.create!(
      status: 'pendente',
      amount: 100.0,
      installment: 3,
      payment_method: 'visa'
      ) }
    let!(:approved_receivable) do
      described_class.create!(
        payment_transaction: approved_transaction,
        schedule_date: 1.day.from_now,
        status: 'pendente',
        amount_to_settle: 100.0,
        amount_settled: 0
      )
    end
    let!(:pending_receivable) do
      described_class.create!(
        payment_transaction: pending_transaction,
        schedule_date: Date.current,
        status: 'pendente',
        amount_to_settle: 50.0,
        amount_settled: 0
      )
    end

    describe '.approved' do
      it 'retorna receivables com status aprovado' do
        expect(described_class.approved).to match_array([approved_receivable])
      end
    end

    describe '.pending_today' do
      it 'retorna receivables com a data de hoje e status pendente' do
        expect(described_class.pending_today).to match_array([pending_receivable])
      end
    end

    describe '.all_receivables' do
      it 'retorna todos os receivables associados a qualquer payment_transaction' do
        all_receivables = described_class.all_receivables
        expect(all_receivables).to include(approved_receivable, pending_receivable)
      end
    end
  end

  describe '.liquidate_receivable' do
    let!(:receivable1) do
      described_class.create!(
        payment_transaction: PaymentTransaction.create!(
          status: 'pendente',
          amount: 100.0,
          installment: 3,
          payment_method: 'visa'
        ),
        schedule_date: 1.day.from_now,
        status: 'pendente',
        amount_to_settle: 100.0,
        amount_settled: 0
      )
    end
    let!(:receivable2) do
      described_class.create!(
        payment_transaction: PaymentTransaction.create!(
          status: 'pendente',
          amount: 100.0,
          installment: 3,
          payment_method: 'visa'
        ),
        schedule_date: 2.days.from_now,
        status: 'pendente',
        amount_to_settle: 200.0,
        amount_settled: 0
      )
    end

    it 'atualiza o status para liquidado, seta liquidation_date e amount_settled corretamente' do
      described_class.liquidate_receivable(Receivable.where(status: 'pendente'), Date.current)

      receivable1.reload
      receivable2.reload

      expect(receivable1.status).to eq('liquidado')
      expect(receivable1.liquidation_date).to eq(Date.current)
      expect(receivable1.amount_settled).to eq(receivable1.amount_to_settle)

      expect(receivable2.status).to eq('liquidado')
      expect(receivable2.liquidation_date).to eq(Date.current)
      expect(receivable2.amount_settled).to eq(receivable2.amount_to_settle)
    end
  end

  describe '.create_receivable' do
    let!(:receivable) do
      described_class.create!(
        payment_transaction: PaymentTransaction.create!(
          status: 'pendente',
          amount: 100.0,
          installment: 3,
          payment_method: 'visa'
        ),
        schedule_date: 2.days.from_now,
        status: 'pendente',
        amount_to_settle: 200.0,
        amount_settled: 0
      )
    end

    let!(:transaction) do
      PaymentTransaction.create!(
        amount: 100.0,
        installment: 3,
        payment_method: 'visa',
        status: 'pendente'
      )
    end

    let(:amount_per_receivable) { 50.0 }

    it 'cria receivables referentes às parcelas, com datas e valores corretos' do
      expect do
        described_class.create_receivable(transaction, amount_per_receivable)
      end.to change(Receivable, :count).by(3)

      created_receivables = Receivable.where(payment_transaction_id: transaction.id).order(:installment)


      expect(created_receivables.pluck(:status).uniq).to eq(['pendente'])
      expect(created_receivables.pluck(:amount_to_settle).uniq).to eq([amount_per_receivable])


      created_receivables.each_with_index do |recv, index|
        expect(recv.installment).to eq(index + 1)
        expected_date = transaction.created_at.to_date >> (index + 1)
        expect(recv.schedule_date.to_date).to eq(expected_date)
      end
    end
  end

  describe '.schedule_date' do
    let!(:transaction) do
      described_class.create!(
        amount: 100.0,
        installment: 2,
        payment_method: 'visa',
        status: 'pendente',
        created_at: Time.current
      )
    end
    let(:transaction) { PaymentTransaction.create!(
      status: 'pendente', 
      created_at: Time.current, 
      installment: 2,
      amount: 100.0
      ) }

    it 'calcula a data adicionando o número de meses ao created_at da transaction' do
      schedule = described_class.schedule_date(transaction, 1)
      expected = transaction.created_at + 2.months
      expect(schedule.to_date).to eq(expected.to_date)
    end
  end
end