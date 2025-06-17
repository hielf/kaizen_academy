# Core Domain Models & Relationships

This document outlines the design of the core domain models and their relationships for the Kaizen Academy application.

## User
The base model for all types of users. This will contain shared attributes.
- **Attributes**:
  - `email` (string, unique)
  - `password_digest` (string)
  - `type` (string, for Single Table Inheritance: 'Student', 'Admin')
  - `timestamps`

---

## Student
Represents a student user of the platform. Inherits from `User`.
- **Relationships**:
  - `has_many :enrollments`
  - `has_many :purchases`
  - `has_many :term_subscriptions`
  - `belongs_to :school`

---

## Admin
Represents an administrative user of the platform. Inherits from `User`.

---

## School
Represents an individual institution.
- **Relationships**:
  - `has_many :students`
  - `has_many :terms`
  - `has_many :courses, through: :terms`

---

## Term
Represents a semester period (e.g., Fall 2025).
- **Relationships**:
  - `belongs_to :school`
  - `has_many :courses`
  - `has_many :term_subscriptions`
  - `has_many :licenses`

---

## Course
Represents a specific course.
- **Relationships**:
  - `belongs_to :term`
  - `has_many :purchases`
  - `has_many :enrollments`

---

## Enrollment
Represents a student's access to a specific `Course`.
- **Relationships**:
  - `belongs_to :student`
  - `belongs_to :course`
  - `has_one :purchase` (if access granted via direct purchase)
  - `has_one :term_subscription` (if access granted via term subscription)

---

## Purchase
Represents a direct credit card purchase of an individual `Course`.
- **Relationships**:
  - `belongs_to :student`
  - `belongs_to :course`
  - `has_one :enrollment`

---

## TermSubscription
Represents a student's subscription to a `Term`, granting access to all courses within it.
- **Relationships**:
  - `belongs_to :student`
  - `belongs_to :term`
  - `has_one :payment_method` (Polymorphic: e.g., CreditCardPayment, LicensePayment)

---

## License
Represents a unique, generated code used for `TermSubscription`.
- **Relationships**:
  - `belongs_to :term`
  - `has_one :term_subscription` (as its payment method)
- **Attributes**:
  - `code` (string, unique)
  - `term_id` (integer)
  - `issued_at` (datetime)
  - `redeemed_at` (datetime, nullable)
  - `expires_at` (datetime)
  - `status` (string: 'active', 'redeemed', 'expired') 