require 'rails_helper'

RSpec.describe CreditCardPayment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:last_four) }
    it { should validate_presence_of(:expiry_date) }
    it { should validate_presence_of(:card_type) }
    it { should validate_presence_of(:processed_at) }

    it 'validates last_four format' do
      payment = build(:credit_card_payment, last_four: '12345')
      expect(payment).not_to be_valid
      expect(payment.errors[:last_four]).to include('must be 4 digits')
    end

    it 'validates expiry_date format' do
      payment = build(:credit_card_payment, expiry_date: '13/25')
      expect(payment).not_to be_valid
      expect(payment.errors[:expiry_date]).to include('must be in MM/YY format')
    end
  end

  describe 'associations' do
    it { should have_one(:term_subscription).dependent(:nullify) }
  end

  describe 'callbacks' do
    it 'sets processed_at before validation if nil' do
      payment = build(:credit_card_payment, processed_at: nil)
      expect(payment.processed_at).to be_nil
      payment.valid?
      expect(payment.processed_at).not_to be_nil
    end
  end

  describe '#process_payment!' do
    it 'updates processed_at if nil' do
      payment = create(:credit_card_payment, processed_at: nil)
      expect { payment.process_payment! }.to change { payment.processed_at }.from(nil)
    end

    it 'returns true' do
      payment = create(:credit_card_payment)
      expect(payment.process_payment!).to be true
    end
  end
end
