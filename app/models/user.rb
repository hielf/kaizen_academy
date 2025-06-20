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
end
