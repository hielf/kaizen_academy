class Purchase < ApplicationRecord
  # A purchase is made by a student
  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :purchasable, polymorphic: true # A purchase is for a specific course or term

  # A purchase creates one enrollment
  has_one :enrollment, dependent: :destroy
  
  # A purchase can have one credit card payment
  has_one :credit_card_payment, dependent: :nullify

  validates :student, presence: true
  validates :purchasable, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :purchased_at, presence: true

  # Ensure a purchase is linked to an enrollment upon creation (or soon after)
  # You might add a callback to create enrollment after purchase.
  after_create :create_enrollment

  private

  def create_enrollment
    case purchasable
    when Course
      create_course_enrollment
    when Term
      create_term_enrollment
    end
  end

  def create_course_enrollment
    # Skip if student is already enrolled in this course
    return if student.enrollments.exists?(course: purchasable)
    
    begin
      Enrollment.enroll!(
        student: student,
        course: purchasable,
        enrollment_method: "direct_purchase",
        purchase: self
      )
    rescue ActiveRecord::RecordInvalid => e
      # Log the error
      Rails.logger.warn("Failed to create enrollment for course #{purchasable.id}: #{e.message}")
    end
  end

  def create_term_enrollment
    # For term purchases, create enrollments for all courses in the term
    purchasable.courses.each do |course|
      # Skip if student is already enrolled in this course
      next if student.enrollments.exists?(course: course)
      
      begin
        Enrollment.enroll!(
          student: student,
          course: course,
          enrollment_method: "direct_purchase",
          purchase: self # Example: 1 year access from purchase
        )
      rescue ActiveRecord::RecordInvalid => e
        # Log the error but continue with other courses
        Rails.logger.warn("Failed to create enrollment for course #{course.id}: #{e.message}")
        next
      end
    end
  end
end
