class CreditCardPayment < ApplicationRecord
  # TermSubscription belongs to a polymorphic payment_method.
  # CreditCardPayment is one of the types of payment_method.
  has_one :term_subscription, as: :payment_method, dependent: :nullify
  
  # CreditCardPayment belongs to a purchase
  belongs_to :purchase, optional: true

  validates :last_four, presence: true, format: { with: /\A\d{4}\z/, message: "must be 4 digits" }
  validates :expiry_date, presence: true, format: { with: /\A(0[1-9]|1[0-2])\/\d{2}\z/, message: "must be in MM/YY format" }
  validates :card_type, presence: true # e.g., Visa, Mastercard
  validates :processed_at, presence: true # When payment was processed

  before_validation :set_processed_at, if: -> { processed_at.nil? }

  # Simulate payment processing success
  def process_payment!
    # this would interact with a payment gateway in the future
    # For now, simulate a transaction ID
    if processed_at.nil?
      txn_id = generate_simulated_transaction_id
      update_columns(processed_at: Time.zone.now, transaction_id: txn_id)
      self.transaction_id = txn_id
      self.processed_at = Time.zone.now
    elsif transaction_id.nil?
      txn_id = generate_simulated_transaction_id
      update_columns(transaction_id: txn_id)
      self.transaction_id = txn_id
    end
    true # Assume success
  end

  def processed?
    processed_at.present?
  end

  private

  def set_processed_at
    self.processed_at = Time.zone.now
  end

  def generate_simulated_transaction_id
    # Generate a realistic-looking transaction ID for testing
    # In production, this would come from the payment gateway
    "txn_#{SecureRandom.alphanumeric(24).downcase}"
  end
end
