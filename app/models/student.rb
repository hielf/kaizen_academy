class Student < User
  # A student can have multiple enrollments in courses
  # IMPORTANT: specify foreign_key for STI, as all types are in 'users' table
  has_many :enrollments, foreign_key: :student_id
  has_many :courses, through: :enrollments # Through enrollments for simplicity

  # A student can make multiple direct purchases
  has_many :purchases, foreign_key: :student_id

  # A student can have multiple term subscriptions
  has_many :term_subscriptions, foreign_key: :student_id

  # Students must be associated with a school
  validates :school, presence: { message: "must be associated with a school" }
end