FactoryBot.define do
  factory :enrollment do
    student { nil }
    course { nil }
    purchase { nil }
    term_subscription { nil }
    join_date { "2025-06-16" }
    access_status { "MyString" }
    enrollment_method { "MyString" }
  end
end
