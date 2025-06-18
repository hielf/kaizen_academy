class Student < User
  # A student belongs to a school (for multi-tenancy, if applicable)
  belongs_to :school, optional: true # Optional if initial school assignment isn't strict

  # A student can have multiple enrollments in courses
  # IMPORTANT: specify foreign_key for STI, as all types are in 'users' table
  has_many :enrollments, foreign_key: :student_id
  has_many :courses, through: :enrollments # Through enrollments for simplicity

  # A student can make multiple direct purchases
  has_many :purchases, foreign_key: :student_id

  # A student can have multiple term subscriptions
  has_many :term_subscriptions, foreign_key: :student_id

  # Add any student-specific validations or methods here
  # Example: validates :school, presence: true, if: :school_specific_student?
  # You might define `school_specific_student?` based on your multi-tenancy strategy

  # For the take-home, assume students generally belong to a school
  validates :school, presence: { message: "must be associated with a school" }
end