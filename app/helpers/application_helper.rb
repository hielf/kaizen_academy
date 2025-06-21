module ApplicationHelper
  def signed_purchasable(purchasable = nil)
    return nil unless purchasable

    data_to_sign = {
      type: purchasable.class.name,
      id: purchasable.id
    }
    Rails.application.message_verifier('purchasable-item').generate(data_to_sign)
  end
end
