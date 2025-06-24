FactoryBot.define do
  factory :credit_card_payment, class: 'CreditCardPayment' do
    last_four { '4242' } # Common test card last 4 digits
    expiry_date { '12/25' } # Valid future date
    card_type { 'Visa' }
    processed_at { Time.zone.now }
    transaction_id { "txn_#{SecureRandom.alphanumeric(24).downcase}" }
    
    # Optional association with purchase
    association :purchase, factory: :purchase
  end
end
