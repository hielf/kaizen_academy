FactoryBot.define do
  factory :purchase do
    student { nil }
    association :purchasable, factory: :course
    amount { "9.99" }
    transaction_id { "MyString" }
    purchased_at { "2025-06-16 23:38:32" }
  end
end
