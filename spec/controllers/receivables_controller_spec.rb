require 'rails_helper'

RSpec.describe ReceivablesController, type: :controller do
    describe 'GET #index' do
      let(:receivable_service) { instance_double(Receivables::ReceivablesService) }
      
      before do
        allow(Receivables::ReceivablesService).to receive(:new).and_return(receivable_service)
      end
  
      context 'when fetching all receivables' do
        it 'returns all receivables' do
          receivables = double('ActiveRecord::Relation')
          allow(receivable_service).to receive(:load_all_receivables).and_return(receivables)
  
          get :index
          expect(response).to have_http_status(:ok)
        end
      end
  
      context 'when fetching only approved receivables' do
        it 'returns approved receivables' do
          receivables = double('ActiveRecord::Relation')
          allow(receivable_service).to receive(:load_approved_receivables).and_return(receivables)
  
          get :index, params: { approved_only: true }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end