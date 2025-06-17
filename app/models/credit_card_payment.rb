class CreditCardPayment < ApplicationRecord
  # TermSubscription belongs to a polymorphic payment_method.
  # CreditCardPayment is one of the types of payment_method.
  has_one :term_subscription, as: :payment_method, dependent: :nullify

  validates :last_four, presence: true, format: { with: /\A\d{4}\z/, message: "must be 4 digits" }
  validates :expiry_date, presence: true, format: { with: /\A(0[1-9]|1[0-2])\/\d{2}\z/, message: "must be in MM/YY format" }
  validates :card_type, presence: true # e.g., Visa, Mastercard
  validates :processed_at, presence: true, default: -> { 'NOW()' } # When payment was processed

  # Simulate payment processing success
  def process_payment!
    # this would interact with a payment gateway in the future
    update(processed_at: Time.zone.now) if processed_at.nil?
    true # Assume success
  end
end
