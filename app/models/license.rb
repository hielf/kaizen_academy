class License < ApplicationRecord
  # A license is issued for a specific term
  belongs_to :term

  # A license can lead to one term subscription (polymorphic payment method for TermSubscription)
  has_one :term_subscription, as: :payment_method, dependent: :nullify # This makes License a 'payment_method' type

  validates :code, presence: true, uniqueness: true
  validates :term, presence: true
  validates :issued_at, presence: true
  validates :expires_at, presence: true
  validates :status, presence: true, inclusion: { in: %w(active redeemed expired invalid) }
  validates :expires_at, comparison: { greater_than: :issued_at, message: "must be after issued date" }

  # Ensure redeemed_at is present if status is 'redeemed'
  validates :redeemed_at, presence: true, if: -> { status == 'redeemed' }

  # Callbacks for status management
  before_validation :set_default_status, on: :create
  before_update :set_redeemed_at_if_status_changed_to_redeemed

  # Helper methods for status checks
  def active?
    status == 'active' && Time.zone.now.between?(issued_at, expires_at) && redeemed_at.nil?
  end

  def redeemed?
    status == 'redeemed' && redeemed_at.present?
  end

  def expired?
    status == 'expired' || (expires_at.present? && Time.zone.now > expires_at)
  end

  # redeem the license
  def redeem!(student)
    # Ensure license is active and not already redeemed/expired
    return false unless active?

    # Mark license as redeemed
    self.status = 'redeemed'
    self.redeemed_at = Time.zone.now
    save!

    # Create the TermSubscription associated with this license
    TermSubscription.create!(
      student: student,
      term: term,
      start_date: term.start_date, # Subscription validity matches term dates
      end_date: term.end_date,
      status: 'active',
      subscription_type: 'license',
      payment_method: self # Polymorphic association to this license
    )
    true
  rescue StandardError => e
    Rails.logger.error("Failed to redeem license #{code}: #{e.message}")
    false
  end

  private

  def set_default_status
    self.status ||= 'active'
  end

  def set_redeemed_at_if_status_changed_to_redeemed
    if status_changed? && status == 'redeemed' && redeemed_at.nil?
      self.redeemed_at = Time.zone.now
    end
  end
end
