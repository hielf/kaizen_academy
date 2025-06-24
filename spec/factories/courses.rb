FactoryBot.define do
  factory :course do
    sequence(:title) { |n| "Course #{n}" }
    description { "A comprehensive course covering essential topics" }
    price { 99.99 }
    association :school
    association :term
    
    trait :free do
      price { 0.0 }
    end
    
    trait :expensive do
      price { 299.99 }
    end
  end
end
