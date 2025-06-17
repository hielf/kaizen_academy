FactoryBot.define do
  factory :purchase do
    student { nil }
    course { nil }
    amount { "9.99" }
    transaction_id { "MyString" }
    purchased_at { "2025-06-16 23:38:32" }
    enrollment { nil }
  end
end
