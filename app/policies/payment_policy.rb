class PaymentPolicy < ApplicationPolicy
  def prepare?
    user.present?
  end

  def new?
    user.present?
  end

  def create?
    user.present?
  end
end 