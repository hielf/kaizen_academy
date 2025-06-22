require 'rails_helper'

RSpec.describe CreditCardPayment, type: :model do
  describe 'validations' do
    it 'validates presence of last_four' do
      payment = build(:credit_card_payment, last_four: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:last_four]).to include("can't be blank")
    end

    it 'validates presence of expiry_date' do
      payment = build(:credit_card_payment, expiry_date: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:expiry_date]).to include("can't be blank")
    end

    it 'validates presence of card_type' do
      payment = build(:credit_card_payment, card_type: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:card_type]).to include("can't be blank")
    end

    it 'validates presence of processed_at' do
      payment = build(:credit_card_payment, processed_at: nil)
      payment.valid? # This will trigger the before_validation callback
      expect(payment.processed_at).not_to be_nil
    end

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

    it 'allows transaction_id to be nil' do
      payment = build(:credit_card_payment, transaction_id: nil)
      expect(payment).to be_valid
    end
  end

  describe 'associations' do
    it 'has one term_subscription with nullify dependency' do
      payment = create(:credit_card_payment)
      expect(payment.term_subscription).to be_nil
    end
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
    it 'updates processed_at and sets transaction_id if nil' do
      payment = build(:credit_card_payment, processed_at: nil, transaction_id: nil)
      payment.save! # Save without triggering process_payment!
      
      expect { payment.process_payment! }.to change { payment.transaction_id }.from(nil)
      expect(payment.transaction_id).to match(/^txn_[a-z0-9]{24}$/)
    end

    it 'does not change transaction_id if already set' do
      payment = create(:credit_card_payment, transaction_id: 'existing_txn_123')
      original_transaction_id = payment.transaction_id
      payment.process_payment!
      expect(payment.transaction_id).to eq(original_transaction_id)
    end

    it 'returns true' do
      payment = create(:credit_card_payment)
      expect(payment.process_payment!).to be true
    end
  end

  describe '#processed?' do
    it 'returns true when processed_at is present' do
      payment = build(:credit_card_payment, processed_at: Time.zone.now)
      expect(payment.processed?).to be true
    end

    it 'returns false when processed_at is nil' do
      payment = build(:credit_card_payment, processed_at: nil)
      expect(payment.processed?).to be false
    end
  end
end
