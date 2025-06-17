FactoryBot.define do
  factory :credit_card_payment do
    last_four { "MyString" }
    expiry_date { "MyString" }
    card_type { "MyString" }
    processed_at { "2025-06-16 23:40:55" }
  end
end
