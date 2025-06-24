# spec/factories/users.rb
FactoryBot.define do
  # Base factory for shared attributes - not meant to be used directly
  factory :user_base, class: 'User' do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { 'John' }
    last_name { 'Doe' }
  end

  factory :student, class: 'Student', parent: :user_base do
    association :school
    
    trait :with_school do
      association :school
    end
  end

  factory :admin, class: 'Admin', parent: :user_base do
    school { nil } # Platform-wide admin has no assigned school
    
    trait :without_school do
      school { nil }
    end
  end
end
