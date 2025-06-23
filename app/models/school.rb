class School < ApplicationRecord
  has_many :terms
  has_many :courses
  has_many :students # Students belong to schools (via their `school_id` on the `users` table)

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 255 }
end
