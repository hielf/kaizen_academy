FactoryBot.define do
  factory :license do
    sequence(:code) { |n| "LICENSE#{SecureRandom.alphanumeric(8).upcase}#{n}" }
    status { "active" }
    association :term
    issued_at { Time.current }
    expires_at { 1.year.from_now }

    trait :redeemed do
      status { "redeemed" }
      redeemed_at { Time.current }
    end

    trait :expired do
      issued_at { 2.days.ago }
      expires_at { 1.day.ago }
      status { "expired" }
    end
  end
end
