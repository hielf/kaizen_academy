class School < ApplicationRecord
  has_many :terms, dependent: :restrict_with_error
  has_many :courses, dependent: :restrict_with_error
  has_many :students, dependent: :restrict_with_error # Students belong to schools (via their `school_id` on the `users` table)

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 255 }
end
