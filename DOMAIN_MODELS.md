# Core Domain Models & Relationships

This document outlines the design of the core domain models and their relationships for the Kaizen Academy application.

## User
The base model for all types of users using Single Table Inheritance (STI). Uses Devise for authentication.
- **Attributes**:
  - `email` (string, unique, required)
  - `encrypted_password` (string, required)
  - `reset_password_token` (string, unique)
  - `reset_password_sent_at` (datetime)
  - `remember_created_at` (datetime)
  - `type` (string, STI discriminator: 'Student', 'Admin', default: 'Student')
  - `first_name` (string, required)
  - `last_name` (string, required)
  - `school_id` (integer, optional, foreign key to schools)
  - `timestamps`
- **Validations**:
  - Email presence, uniqueness, and format validation
  - Type presence
  - First and last name presence
- **Methods**:
  - `student?` - checks if user is a Student
  - `admin?` - checks if user is an Admin
  - `after_sign_in_path_for` - custom Devise redirect logic

---

## Student
Represents a student user of the platform. Inherits from `User`.
- **Relationships**:
  - `belongs_to :school` (required)
  - `has_many :enrollments, foreign_key: :student_id`
  - `has_many :courses, through: :enrollments`
  - `has_many :purchases, foreign_key: :student_id`
  - `has_many :term_subscriptions, foreign_key: :student_id`
- **Validations**:
  - School presence required
- **Callbacks**:
  - `before_destroy :check_for_associated_records` - prevents deletion if associated records exist

---

## Admin
Represents an administrative user of the platform. Inherits from `User`.
- **Notes**:
  - Platform-wide admins (school_id is nil)
  - No enrollments, purchases, or term subscriptions
  - Permissions managed through authorization policies

---

## School
Represents an individual institution.
- **Attributes**:
  - `name` (string, required, unique, 3-255 characters)
  - `status` (string, default: 'active')
  - `timestamps`
- **Relationships**:
  - `has_many :students, dependent: :restrict_with_error`
  - `has_many :terms, dependent: :restrict_with_error`
  - `has_many :courses, dependent: :restrict_with_error`
- **Validations**:
  - Name presence, uniqueness, and length validation

---

## Term
Represents a semester period (e.g., Fall 2025).
- **Attributes**:
  - `name` (string, required)
  - `start_date` (date, required)
  - `end_date` (date, required)
  - `description` (text)
  - `school_id` (integer, required, foreign key)
  - `price` (decimal, required, >= 0)
  - `timestamps`
- **Relationships**:
  - `belongs_to :school`
  - `has_many :courses, dependent: :restrict_with_error`
  - `has_many :term_subscriptions, dependent: :restrict_with_error`
  - `has_many :students, through: :term_subscriptions`
  - `has_many :purchases, as: :purchasable, dependent: :restrict_with_error`
  - `has_many :enrollments, through: :courses`
  - `has_many :licenses, dependent: :restrict_with_error`
- **Validations**:
  - Name presence
  - Start and end date presence
  - Price presence and numericality (>= 0)
  - End date must be after start date
  - Name uniqueness per school
- **Scopes**:
  - `available` - terms not yet ended
  - `active` - currently running terms
  - `upcoming` - future terms
  - `expired` - past terms
  - `for_school(school)` - terms for specific school
- **Methods**:
  - `available?` - checks if term is currently available

---

## Course
Represents a specific course within a term.
- **Attributes**:
  - `title` (string, required)
  - `description` (text, required)
  - `school_id` (integer, required, foreign key)
  - `term_id` (integer, required, foreign key)
  - `price` (decimal, required, >= 0)
  - `timestamps`
- **Relationships**:
  - `belongs_to :school`
  - `belongs_to :term`
  - `has_many :enrollments, dependent: :restrict_with_error`
  - `has_many :purchases, as: :purchasable, dependent: :restrict_with_error`
- **Validations**:
  - Title and description presence
  - Price presence and numericality (>= 0)
  - Title uniqueness per school

---

## Enrollment
Represents a student's access to a specific `Course`.
- **Attributes**:
  - `student_id` (integer, required, foreign key to users)
  - `course_id` (integer, required, foreign key)
  - `purchase_id` (integer, optional, foreign key)
  - `term_subscription_id` (integer, optional, foreign key)
  - `join_date` (date, required)
  - `start_date` (date, required)
  - `end_date` (date, required)
  - `access_status` (string, default: 'active')
  - `enrollment_method` (string, required, enum values)
  - `timestamps`
- **Relationships**:
  - `belongs_to :student, class_name: "User", foreign_key: "student_id"`
  - `belongs_to :course`
  - `belongs_to :purchase, optional: true`
  - `belongs_to :term_subscription, optional: true`
- **Validations**:
  - Student and course presence
  - Join, start, and end date presence
  - Access status presence
  - Enrollment method presence and inclusion validation
  - Student uniqueness per course
- **Callbacks**:
  - `before_validation :set_join_date` (on create)
  - `before_validation :set_default_access_status` (on create)
- **Methods**:
  - `active?` - checks if enrollment is currently active
  - `self.enroll!` - class method to create enrollments with proper defaults

**Enrollment Methods**:
- `direct_purchase`
- `term_subscription`
- `admin_override`
- `term_subscription_credit_card`
- `term_subscription_license`
- `term_subscription_admin`

---

## Purchase
Represents a direct credit card purchase of an individual `Course` or `Term`.
- **Attributes**:
  - `student_id` (integer, required, foreign key to users)
  - `amount` (decimal, required, >= 0)
  - `transaction_id` (string, optional)
  - `purchased_at` (datetime, required, default: now)
  - `purchasable_type` (string, required, polymorphic)
  - `purchasable_id` (integer, required, polymorphic)
  - `timestamps`
- **Relationships**:
  - `belongs_to :student, class_name: "User", foreign_key: "student_id"`
  - `belongs_to :purchasable, polymorphic: true`
  - `has_one :enrollment, dependent: :destroy`
  - `has_one :credit_card_payment, dependent: :nullify`
- **Validations**:
  - Student and purchasable presence
  - Amount presence and numericality (>= 0)
  - Purchased at presence
- **Callbacks**:
  - `after_create :create_enrollment` - automatically creates enrollments

---

## TermSubscription
Represents a student's subscription to a `Term`, granting access to all courses within it.
- **Attributes**:
  - `student_id` (integer, required, foreign key to users)
  - `term_id` (integer, required, foreign key)
  - `payment_method_type` (string, polymorphic)
  - `payment_method_id` (integer, polymorphic)
  - `start_date` (date, required)
  - `end_date` (date, required)
  - `status` (string, default: 'active')
  - `subscription_type` (string, required, enum values)
  - `timestamps`
- **Relationships**:
  - `belongs_to :student, class_name: "User", foreign_key: "student_id"`
  - `belongs_to :term`
  - `belongs_to :payment_method, polymorphic: true, optional: true`
  - `has_many :enrollments, dependent: :destroy`
- **Validations**:
  - Student and term presence
  - Start and end date presence
  - Status presence and inclusion validation
  - Subscription type presence and inclusion validation
  - Student uniqueness per term (if active)
- **Callbacks**:
  - `after_create :create_term_enrollments` - creates enrollments for all term courses
- **Methods**:
  - `active?` - checks if subscription is currently active

**Subscription Types**:
- `credit_card`
- `license`
- `admin_created`

**Status Values**:
- `active`
- `expired`
- `pending`
- `cancelled`

---

## License
Represents a unique, generated code used for `TermSubscription`.
- **Attributes**:
  - `code` (string, required, unique, auto-generated)
  - `term_id` (integer, required, foreign key)
  - `issued_at` (datetime, required)
  - `redeemed_at` (datetime, optional)
  - `expires_at` (datetime, required)
  - `status` (string, default: 'active')
  - `timestamps`
- **Relationships**:
  - `belongs_to :term`
  - `has_one :term_subscription, as: :payment_method, dependent: :nullify`
- **Validations**:
  - Code presence and uniqueness
  - Term presence
  - Issued at and expires at presence
  - Status presence and inclusion validation
  - Expires at must be after issued at
  - Redeemed at presence if status is 'redeemed'
- **Callbacks**:
  - `before_validation :set_default_status` (on create)
  - `before_validation :generate_unique_code` (on create)
  - `before_validation :set_redeemed_at_if_status_changed_to_redeemed` (on update)
  - `before_destroy :prevent_destroy_if_redeemed`
- **Methods**:
  - `active?` - checks if license is active and not expired/redeemed
  - `redeemed?` - checks if license has been redeemed
  - `expired?` - checks if license has expired
  - `redeem!(student)` - redeems license and creates term subscription
  - `generate_unique_code` - generates unique 16-character alphanumeric code

**Status Values**:
- `active`
- `redeemed`
- `expired`
- `invalid`

---

## CreditCardPayment
Represents a credit card payment used as a payment method for a `TermSubscription` or for direct purchases.
- **Attributes**:
  - `last_four` (string, required, 4 digits)
  - `expiry_date` (string, required, MM/YY format)
  - `card_type` (string, required, e.g., Visa, Mastercard)
  - `processed_at` (datetime, required, default: now)
  - `transaction_id` (string, optional, auto-generated)
  - `purchase_id` (integer, optional, foreign key)
  - `timestamps`
- **Relationships**:
  - `has_one :term_subscription, as: :payment_method, dependent: :nullify`
  - `belongs_to :purchase, optional: true`
- **Validations**:
  - Last four digits presence and format (4 digits)
  - Expiry date presence and format (MM/YY)
  - Card type presence
  - Processed at presence
- **Callbacks**:
  - `before_validation :set_processed_at` (if processed_at is nil)
- **Methods**:
  - `process_payment!` - simulates payment processing and generates transaction ID
  - `processed?` - checks if payment has been processed
  - `generate_simulated_transaction_id` - generates realistic transaction ID for testing