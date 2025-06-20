class Term < ApplicationRecord
  belongs_to :school

  # A term can have many courses associated with it.
  # Using has_and_belongs_to_many for simplicity in this take-home.
  # For more complex scenarios (e.g., specific section numbers per term),
  # a `CourseOffering` join model might be preferred.
  has_many :courses, dependent: :nullify

  has_many :term_subscriptions, dependent: :destroy # Subscriptions for this term

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :end_date, comparison: { greater_than: :start_date, message: "must be after the start date" }

  # Ensure term names are unique per school
  validates :name, uniqueness: { scope: :school_id, message: "already exists for this school" }

  has_many :enrollments, through: :courses
  has_many :licenses, dependent: :destroy

  # Helper to check if the term is currently available
  def available?
    end_date > Time.zone.now
  end
end
