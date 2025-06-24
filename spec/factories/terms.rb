FactoryBot.define do
  factory :term do
    sequence(:name) { |n| "Term #{n}" }
    description { "A comprehensive term with multiple courses" }
    start_date { Date.current }
    end_date { 3.months.from_now.to_date }
    price { 299.99 }
    association :school
    
    trait :past do
      start_date { 6.months.ago.to_date }
      end_date { 3.months.ago.to_date }
    end
    
    trait :future do
      start_date { 3.months.from_now.to_date }
      end_date { 6.months.from_now.to_date }
    end
  end
end
