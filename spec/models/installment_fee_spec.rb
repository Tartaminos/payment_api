require 'rails_helper'

RSpec.describe InstallmentFee, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      fee = described_class.new(installments: 3, fee_percentage: 2.5)
      expect(fee).to be_valid
    end

    it 'requires installments to be present and an integer between 1 and 12' do
      fee = described_class.new(installments: nil, fee_percentage: 2.5)
      expect(fee).not_to be_valid
      expect(fee.errors[:installments]).to include('can\'t be blank')

      fee.installments = 13
      fee.validate
      expect(fee.errors[:installments]).to include('must be less than or equal to 12')

      fee.installments = 0
      fee.validate
      expect(fee.errors[:installments]).to include('must be greater than 0')
    end

    it 'requires fee_percentage to be present and greater than or equal to 0' do
      fee = described_class.new(installments: 1, fee_percentage: nil)
      expect(fee).not_to be_valid
      expect(fee.errors[:fee_percentage]).to include('can\'t be blank')

      fee.fee_percentage = -1
      fee.validate
      expect(fee.errors[:fee_percentage]).to include('must be greater than or equal to 0')
    end
  end

  describe '.installment_fee_percentage' do
    context 'when there is a record for the given installment' do
      it 'returns the correct fee_percentage' do

        described_class.create!(installments: 3, fee_percentage: 2.5)

        result = described_class.installment_fee_percentage(3)
        expect(result).to eq(2.5)
      end
    end

    context 'when there is no record for the given installment' do
      it 'levanta um erro ou retorna nil (dependendo da implementação)' do

        expect {
          described_class.installment_fee_percentage(99)
        }.to raise_error(NoMethodError)
      end
    end
  end
end