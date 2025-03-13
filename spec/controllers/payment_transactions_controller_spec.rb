require 'rails_helper'

RSpec.describe PaymentTransactionsController, type: :controller do
  let(:valid_params) { { transaction: { amount: 100.0, installment: 2, payment_method: 'master' } } }
  let(:invalid_params) { { transaction: { amount: nil, installment: nil, payment_method: nil } } }

  describe 'POST #create' do
    context 'transaction criada com sucess' do
      it 'retorna sucesso na resposta' do
        transaction_service = instance_double(Payments::PaymentTransactionService)

        allow(Payments::PaymentTransactionService).to receive(:new).and_return(transaction_service)

        transaction = double('Transaction', id: 1, status: 'approved', save: true)

        allow(transaction_service).to receive(:create_transaction).and_return(transaction)
        
        gateway_service = instance_double(Gateways::PaymentGatewayService)

        allow(Gateways::PaymentGatewayService).to receive(:new).with(transaction).and_return(gateway_service)
        allow(gateway_service).to receive(:process_transaction).and_return({ message: 'Transação aprovada e em processamento.' })

        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['status']).to eq('approved')
      end
    end

    context 'quando a transação falha' do
      it 'retorna mensagem de erro' do
        transaction_service = instance_double(Payments::PaymentTransactionService)

        allow(Payments::PaymentTransactionService).to receive(:new).and_return(transaction_service)

        transaction = double('Transaction', save: false, errors: double(messages: { base: ["Transação reprovada: número de parcelas ímpar."] }))

        allow(transaction_service).to receive(:create_transaction).and_return(transaction)

        post :create, params: invalid_params
    
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_body = JSON.parse(response.body)
        # Verificamos se a resposta contém a mensagem de erro em :base
        expect(parsed_body['errors']).to eq({ 'base' => ["Transação reprovada: número de parcelas ímpar."] })
      end
    end
  end

  describe 'GET #index' do
    it 'returns a list of transactions within a date range' do
      transaction_service = instance_double(Payments::PaymentTransactionService)
      allow(Payments::PaymentTransactionService).to receive(:new).and_return(transaction_service)
      transactions = double('ActiveRecord::Relation')
      allow(transaction_service).to receive(:load_transaction_by_date_range).and_return(transactions)
      allow(transactions).to receive(:offset).and_return(transactions)
      allow(transactions).to receive(:limit).and_return(transactions)

      get :index, params: { start_date: '01/01/2025', end_date: Date.current }
      expect(response).to have_http_status(:ok)
    end
  end
end