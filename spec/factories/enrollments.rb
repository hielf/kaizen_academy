FactoryBot.define do
  factory :enrollment do
    association :student
    association :course
    start_date { Date.current }
    end_date { 3.months.from_now.to_date }
    join_date { Date.current }
    access_status { "active" }
    enrollment_method { "direct_purchase" }
    
    trait :inactive do
      access_status { "inactive" }
    end
    
    trait :pending do
      access_status { "pending" }
    end
    
    trait :with_purchase do
      association :purchase
    end
    
    trait :with_term_subscription do
      association :term_subscription
      enrollment_method { "term_subscription" }
    end
    
    trait :admin_override do
      enrollment_method { "admin_override" }
    end
    
    trait :term_subscription_credit_card do
      enrollment_method { "term_subscription_credit_card" }
    end
    
    trait :term_subscription_license do
      enrollment_method { "term_subscription_license" }
    end
    
    trait :term_subscription_admin do
      enrollment_method { "term_subscription_admin" }
    end
  end
end
