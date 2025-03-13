require 'rails_helper'

RSpec.describe Receivables::ReceivablesService, type: :service do
  subject(:service) { described_class.new }

  describe '#load_approved_receivables' do
    it 'chama o scope approved de Receivable' do
      expect(Receivable).to receive(:approved)
      service.load_approved_receivables
    end
  end

  describe '#load_pending_today_receivables' do
    it 'chama o scope pending_today de Receivable' do
      expect(Receivable).to receive(:pending_today)
      service.load_pending_today_receivables
    end
  end

  describe '#liquidate_receivable' do
    let(:receivables_to_liquidate) { double('ActiveRecord::Relation') }
    let(:date) { Date.current }

    it 'chama Receivable.liquidate_receivable com os parâmetros corretos' do
      expect(Receivable).to receive(:liquidate_receivable).with(receivables_to_liquidate, date)
      service.liquidate_receivable(receivables_to_liquidate, date)
    end
  end

  describe '#create_receivable' do
    let(:transaction) { instance_double('PaymentTransaction', id: 1) }
    let(:amount_per_receivable) { 100.0 }

    it 'chama Receivable.create_receivable com os parâmetros corretos' do
      expect(Receivable).to receive(:create_receivable).with(transaction, amount_per_receivable)
      service.create_receivable(transaction, amount_per_receivable)
    end
  end

  describe '#load_all_receivables' do
    it 'chama o scope all_receivables de Receivable' do
      expect(Receivable).to receive(:all_receivables)
      service.load_all_receivables
    end
  end
end