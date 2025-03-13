require 'rails_helper'

RSpec.describe Receivables::LiquidationService, type: :service do
  describe '#liquidate' do
    let(:date) { Date.current }
    let(:receivables_service) { instance_double(Receivables::ReceivablesService) }
    let(:receivables_to_liquidate) { double('ActiveRecord::Relation') }

    it 'carrega os receivables pendentes e chama liquidate_receivable com a data fornecida' do
      allow(Receivables::ReceivablesService).to receive(:new).and_return(receivables_service)
      allow(receivables_service).to receive(:load_pending_today_receivables).and_return(receivables_to_liquidate)
      allow(receivables_service).to receive(:liquidate_receivable)

      service = described_class.new
      service.liquidate(date)

      expect(receivables_service).to have_received(:load_pending_today_receivables)
      expect(receivables_service).to have_received(:liquidate_receivable).with(receivables_to_liquidate, date)
    end
  end
end