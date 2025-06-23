class Term < ApplicationRecord
  belongs_to :school

  # A term can have many courses associated with it.
  # Using has_and_belongs_to_many for simplicity in this take-home.
  # For more complex scenarios (e.g., specific section numbers per term),
  # a `CourseOffering` join model might be preferred.
  has_many :courses, dependent: :restrict_with_error

  has_many :term_subscriptions, dependent: :destroy # Subscriptions for this term
  has_many :students, through: :term_subscriptions
  has_many :purchases, as: :purchasable, dependent: :destroy # Terms can be directly purchased

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :end_date, comparison: { greater_than: :start_date, message: "must be after the start date" }

  # Ensure term names are unique per school
  validates :name, uniqueness: { scope: :school_id, message: "already exists for this school" }

  has_many :enrollments, through: :courses
  has_many :licenses, dependent: :destroy

  # Scopes for filtering terms
  scope :available, -> { where("end_date > ?", Time.zone.now) }
  scope :active, -> { where("start_date <= ? AND end_date > ?", Time.zone.now, Time.zone.now) }
  scope :upcoming, -> { where("start_date > ?", Time.zone.now) }
  scope :expired, -> { where("end_date <= ?", Time.zone.now) }
  scope :for_school, ->(school) { where(school: school) }

  before_destroy :check_for_associated_records

  # Helper to check if the term is currently available
  def available?
    end_date > Time.zone.now
  end

  private

  def check_for_associated_records
    if enrollments.exists?
      errors.add(:base, "Cannot delete term with associated enrollments")
      throw(:abort)
    end
    if term_subscriptions.exists?
      errors.add(:base, "Cannot delete term with associated term subscriptions")
      throw(:abort)
    end
    if purchases.exists?
      errors.add(:base, "Cannot delete term with associated purchases")
      throw(:abort)
    end
    if licenses.exists?
      errors.add(:base, "Cannot delete term with associated licenses")
      throw(:abort)
    end
  end
end
