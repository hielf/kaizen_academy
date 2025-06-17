class Purchase < ApplicationRecord
  # A purchase is made by a student
  belongs_to :student, class_name: 'User', foreign_key: 'student_id'
  belongs_to :course # A purchase is for a specific course

  # A purchase creates one enrollment
  has_one :enrollment, dependent: :destroy

  validates :student, presence: true
  validates :course, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :purchased_at, presence: true

  # Ensure a purchase is linked to an enrollment upon creation (or soon after)
  # You might add a callback to create enrollment after purchase.
  after_create :create_course_enrollment

  private

  def create_course_enrollment
    Enrollment.find_or_create_by!(
      student: student,
      course: course,
      start_date: purchased_at.to_date,
      end_date: purchased_at.to_date + 1.year, # Example: 1 year access from purchase
      access_status: 'active',
      enrollment_method: 'direct_purchase',
      purchase: self # Link this purchase to the enrollment
    )
  end
end
