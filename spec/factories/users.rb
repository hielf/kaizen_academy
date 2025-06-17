# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    first_name { 'John' }
    last_name { 'Doe' }
    type { 'User' } # Default type for base User factory

    factory :student, parent: :user do
      type { 'Student' }
      # Associate with a school for valid student creation if validation is active
      association :school
    end

    factory :admin, parent: :user do
      type { 'Admin' }
      school { nil } # Platform-wide admin has no assigned school
    end
  end
end