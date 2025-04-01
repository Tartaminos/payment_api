# spec/models/payment_transaction_spec.rb
require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
    describe 'associations' do
        it 'permite que vários Receivables façam referência a ele pela coluna transaction_id, com dependent: :destroy' do

          payment_transaction = PaymentTransaction.create!(
            amount: 100.0,
            installment: 2,
            payment_method: 'visa',
            status: 'pendente',
            created_at: Time.current
          )
    

          receivable1 = Receivable.create!(
            payment_transaction_id: payment_transaction.id,
            installment: 1,
            schedule_date: 1.day.from_now,
            status: 'pendente',
            amount_to_settle: 50.0,
            amount_settled: 0
          )
    
          receivable2 = Receivable.create!(
            payment_transaction_id: payment_transaction.id,
            installment: 2,
            schedule_date: 2.days.from_now,
            status: 'pendente',
            amount_to_settle: 50.0,
            amount_settled: 0
          )
    

          expect(receivable1.payment_transaction_id).to eq(payment_transaction.id)
          expect(receivable2.payment_transaction_id).to eq(payment_transaction.id)
    

          expect(receivable1.payment_transaction).to eq(payment_transaction)
          expect(receivable2.payment_transaction).to eq(payment_transaction)
    

          payment_transaction.destroy
          expect(Receivable.find_by(id: receivable1.id)).to be_nil
          expect(Receivable.find_by(id: receivable2.id)).to be_nil
        end
      end

  describe '.load_transaction_by_id' do
    let!(:transaction) do
      described_class.create!(
        amount: 100.0,
        installment: 3,
        payment_method: 'visa',
        status: 'pendente'
      )
    end

    context 'quando a transaction tem o id existente' do
      it 'retorna corretamente' do
        expect(described_class.load_transaction_by_id(transaction.id)).to eq(transaction)
      end
    end

    context 'quando o id nao existe' do
      it 'retorna nil' do
        expect(described_class.load_transaction_by_id(999_999)).to be_nil
      end
    end
  end

  describe '.load_transaction_by_date_range' do
    let!(:transaction_in_range) { described_class.create!(
      created_at: 4.days.ago,
      amount: 100.0,
      installment: 3,
      payment_method: 'visa',
      status: 'pendente'
      ) }
    let!(:transaction_out_range1) { described_class.create!(
      created_at: 1.day.ago,
      amount: 100.0,
      installment: 3,
      payment_method: 'visa',
      status: 'pendente'
    ) }
    let!(:transaction_out_range2) { described_class.create!(
      created_at: 10.days.ago,
      amount: 100.0,
      installment: 3,
      payment_method: 'visa',
      status: 'pendente'
    ) }

    it 'retorna transactions em range de data especifica' do
      start_date = 5.days.ago.to_date
      end_date   = 4.days.ago.to_date

      results = described_class.load_transaction_by_date_range(start_date, end_date)
      expect(results).to contain_exactly(transaction_in_range)
    end

    it 'se nao tiver nenhuma na data especifica retorna vazio' do
      start_date = 30.days.ago.to_date
      end_date   = 20.days.ago.to_date

      results = described_class.load_transaction_by_date_range(start_date, end_date)
      expect(results).to be_empty
    end
  end

  describe '.create_transaction' do 
    let(:transaction_params) do
      {
        amount: 100.0,
        installment: 3,
        payment_method: 'elo'
      }
    end

    it 'cria uma nova PaymentTransaction com os parâmetros fornecidos' do
      payment_transaction = described_class.create_transaction(transaction_params)

      expect(payment_transaction).to be_a(PaymentTransaction)

      expect(payment_transaction.amount).to eq(100.0)
      expect(payment_transaction.installment).to eq(3)
      expect(payment_transaction.payment_method).to eq('elo')

      expect(payment_transaction).to_not be_persisted
    end

  end
end
