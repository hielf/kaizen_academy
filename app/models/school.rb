class School < ApplicationRecord
  has_many :terms
  has_many :courses
  has_many :students # Students belong to schools (via their `school_id` on the `users` table)

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 255 }

  before_destroy :check_for_associated_records

  private

  def check_for_associated_records
    if terms.exists?
      errors.add(:base, "Cannot delete school with associated terms")
      throw(:abort)
    end

    if courses.exists?
      errors.add(:base, "Cannot delete school with associated courses")
      throw(:abort)
    end

    if students.exists?
      errors.add(:base, "Cannot delete school with associated students")
      throw(:abort)
    end
  end
end
