require 'rails_helper'

RSpec.describe Payments::PaymentTransactionService, type: :service do
  let(:params) { { amount: 100.0, installment: 2, payment_method: 'credit_card' } }
  subject(:service) { described_class.new(params) }

  describe '#create_transaction' do
    it 'inicializa um novo PaymentTransaction com os parâmetros fornecidos' do
      expect(PaymentTransaction).to receive(:new).with(params)

      service.create_transaction(params)
    end
  end

  describe '#load_transaction_by_id' do
    it 'chama o método load_transaction_by_id de PaymentTransaction com o ID fornecido' do
      expect(PaymentTransaction).to receive(:load_transaction_by_id).with(123)

      service.load_transaction_by_id(123)
    end
  end

  describe '#load_transaction_by_date_range' do
    it 'chama o método load_transaction_by_date_range de PaymentTransaction com as datas fornecidas' do
      start_date = Date.yesterday
      end_date   = Date.today

      expect(PaymentTransaction).to receive(:load_transaction_by_date_range).with(start_date, end_date)
      
      service.load_transaction_by_date_range(start_date, end_date)
    end
  end
end
