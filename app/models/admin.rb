class Admin < User
  # Admins manage the entire system
  # Their permissions will be broader, managed through authorization policies that grant access across all schools.
  # The 'school_id' column on the base User table will be nil for platform-wide Admins.

  # Add any admin-specific validations or methods here
  # Admins typically don't have enrollments, purchases, or term subscriptions.
end