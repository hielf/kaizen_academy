FactoryBot.define do
  factory :term_subscription do
    student { nil }
    term { nil }
    start_date { "2025-06-16" }
    end_date { "2025-06-16" }
    status { "MyString" }
    subscription_type { "MyString" }
    payment_method_id { 1 }
    payment_method_type { "MyString" }
  end
end
