class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # STI: The 'type' column will store the class name (e.g., 'Student', 'Admin')

  # Associations
  belongs_to :school, optional: true

  # Basic validations for shared attributes
  validates :email, presence: true, uniqueness: true
  validate :email_format_validation
  validates :type, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  # --- Role-checking helper methods (optional but useful) ---
  def student?
    type == "Student"
  end

  def admin?
    type == "Admin"
  end

  # Define default Devise redirect path after sign in, useful for STI
  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      # Redirect to root path where admin dashboard is now integrated
      Rails.application.routes.url_helpers.root_path
    elsif resource.is_a?(Student)
      # Assuming a student dashboard or courses page. Make sure this route exists later.
      Rails.application.routes.url_helpers.student_dashboard_path
    else
      super # Fallback to Devise's default behavior
    end
  end

  private

  def email_format_validation
    return if email.blank?

    local_part, domain = email.split('@')

    if local_part.blank? || domain.blank?
      errors.add(:email, "must be a valid email address")
      return
    end

    if local_part.length < 2
      errors.add(:email, "local part must be at least 2 characters")
    end

    domain_parts = domain.split('.')
    if domain_parts.length < 2 || domain_parts.any?(&:empty?)
      errors.add(:email, "domain must be properly formatted (e.g., example.com)")
    elsif domain_parts.last.length < 2
      errors.add(:email, "domain extension must be at least 2 characters")
    end
  end
end
