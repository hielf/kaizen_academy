class Enrollment < ApplicationRecord
  belongs_to :student, class_name: 'User', foreign_key: 'student_id'
  belongs_to :course
  belongs_to :purchase, optional: true
  belongs_to :term_subscription, optional: true

  validates :student, presence: true
  validates :course, presence: true
  validates :join_date, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :access_status, presence: true
  validates :enrollment_method, presence: true, inclusion: { in: %w(direct_purchase term_subscription admin_override) }

  # Ensure a student can only be enrolled in a specific course once (for now)
  validates :student_id, uniqueness: { scope: :course_id, message: "is already enrolled in this course" }

  # check if enrollment is currently active
  def active?
    Time.zone.now.between?(start_date.beginning_of_day, end_date.end_of_day) && access_status == 'active'
  end
end
