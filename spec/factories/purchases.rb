FactoryBot.define do
  factory :purchase do
    association :student
    association :purchasable, factory: :course
    amount { 99.99 }
    transaction_id { "txn_#{SecureRandom.alphanumeric(24).downcase}" }
    purchased_at { Time.current }
    
    trait :for_term do
      association :purchasable, factory: :term
      amount { 299.99 }
    end
    
    trait :for_course do
      association :purchasable, factory: :course
      amount { 99.99 }
    end
  end
end
