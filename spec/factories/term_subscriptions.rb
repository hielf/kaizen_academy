FactoryBot.define do
  factory :term_subscription do
    association :student
    association :term
    start_date { Date.current }
    end_date { 3.months.from_now.to_date }
    status { "active" }
    subscription_type { "credit_card" }
    
    trait :inactive do
      status { "inactive" }
    end
    
    trait :expired do
      status { "expired" }
      end_date { 1.month.ago.to_date }
    end
    
    trait :pending do
      status { "pending" }
    end
    
    trait :cancelled do
      status { "cancelled" }
    end
    
    trait :license do
      subscription_type { "license" }
    end
    
    trait :admin_created do
      subscription_type { "admin_created" }
    end
    
    trait :with_payment_method do
      association :payment_method, factory: :credit_card_payment
    end
  end
end
