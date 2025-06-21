class TermSubscription < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :term

  # Polymorphic association: a term subscription belongs to a specific payment method
  belongs_to :payment_method, polymorphic: true, optional: true # optional: true if admin can create without payment method

  has_many :enrollments, dependent: :destroy # A term subscription grants multiple enrollments (for all courses in term)

  validates :student, presence: true
  validates :term, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active expired pending cancelled] }
  validates :subscription_type, presence: true, inclusion: { in: %w[credit_card license admin_created] }

  # Ensure a student only has one active subscription per term
  validates :student_id, uniqueness: { scope: :term_id, message: "already has an active subscription for this term" }, if: :active_status?

  # Callback to create enrollments for all courses in the term
  after_create :create_term_enrollments

  def active?
    status == "active" && Time.zone.now.between?(start_date.beginning_of_day, end_date.end_of_day)
  end

  private

  def active_status?
    status == "active"
  end

  # Create enrollments for all courses associated with the subscribed term
  def create_term_enrollments
    term.courses.each do |course|
      Enrollment.enroll!(
        student: student,
        course: course,
        enrollment_method: subscription_type == "license" ? "term_subscription_license" : "term_subscription_credit_card",
        term_subscription: self
      )
    end
    # term.courses.each do |course|
    #   Enrollment.find_or_create_by!(
    #     student: student,
    #     course: course,
    #     start_date: start_date,
    #     end_date: end_date,
    #     access_status: "active",
    #     enrollment_method: subscription_type == "license" ? "term_subscription_license" : "term_subscription_credit_card",
    #     term_subscription: self # Link this term subscription to the enrollment
    #   )
    # end
  end
end
