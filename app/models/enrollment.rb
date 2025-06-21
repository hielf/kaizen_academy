class Enrollment < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :course
  belongs_to :purchase, optional: true
  belongs_to :term_subscription, optional: true

  validates :student, presence: true
  validates :course, presence: true
  validates :join_date, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :access_status, presence: true
  validates :enrollment_method, presence: true, inclusion: { in: %w[direct_purchase term_subscription admin_override term_subscription_credit_card term_subscription_license term_subscription_admin] }

  # Ensure a student can only be enrolled in a specific course once (for now)
  validates :student_id, uniqueness: { scope: :course_id, message: "is already enrolled in this course" }

  before_validation :set_join_date, on: :create
  before_validation :set_default_access_status, on: :create

  # check if enrollment is currently active
  def active?
    Time.zone.now.between?(start_date.beginning_of_day, end_date.end_of_day) && access_status == "active"
  end

  def self.enroll!(student:, course:, enrollment_method:, purchase: nil, term_subscription: nil, start_date: nil, end_date: nil)
    # Determine start and end dates if not provided
    if term_subscription
      start_date ||= term_subscription.start_date
      end_date   ||= term_subscription.end_date
    elsif course.term
      start_date ||= course.term.start_date
      end_date   ||= course.term.end_date
    end

    # Default to today for start_date and join_date if still nil
    start_date ||= Time.zone.now

    # End date must be present
    raise "End date must be provided for enrollment" unless end_date

    create!(
      student: student,
      course: course,
      purchase: purchase,
      term_subscription: term_subscription,
      start_date: start_date,
      end_date: end_date,
      enrollment_method: enrollment_method
    )
  end

  private

  def set_join_date
    self.join_date ||= Time.zone.now
  end

  def set_default_access_status
    self.access_status ||= 'active'
  end
end
