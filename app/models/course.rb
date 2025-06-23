class Course < ApplicationRecord
  belongs_to :school

  # A course can be offered in multiple terms.
  # Using has_and_belongs_to_many with Term.
  belongs_to :term

  has_many :enrollments, dependent: :destroy # Students enroll in courses
  has_many :purchases, as: :purchasable, dependent: :destroy # Courses can be directly purchased

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Ensure course titles are unique per school
  validates :title, uniqueness: { scope: :school_id, message: "already exists for this school" }

  before_destroy :check_for_associated_records

  def self.ransackable_attributes(auth_object = nil)
    # ... existing code ...
  end

  private

  def check_for_associated_records
    if enrollments.exists?
      errors.add(:base, "Cannot delete course with associated enrollments")
      throw(:abort)
    end
    if purchases.exists?
      errors.add(:base, "Cannot delete course with associated purchases")
      throw(:abort)
    end
  end
end
