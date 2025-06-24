FactoryBot.define do
  factory :school do
    sequence(:name) { |n| "School #{n}" }
    status { "active" }
    
    trait :inactive do
      status { "inactive" }
    end
  end
end
