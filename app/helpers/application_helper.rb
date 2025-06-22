module ApplicationHelper
  def signed_purchasable(purchasable = nil)
    return nil unless purchasable

    data_to_sign = {
      type: purchasable.class.name,
      id: purchasable.id
    }
    Rails.application.message_verifier('purchasable-item').generate(data_to_sign)
  end

  # Alert helper methods for consistent messaging
  def flash_alert(message, type = :alert)
    flash[type] = message
  end

  def flash_success(message)
    flash[:notice] = message
  end

  def flash_error(message)
    flash[:alert] = message
  end

  def flash_warning(message)
    flash[:warning] = message
  end

  def flash_info(message)
    flash[:info] = message
  end

  # Helper to check if any flash messages exist
  def any_flash_messages?
    flash.any? { |type, message| message.present? && type.to_s != 'notice' }
  end

  # Helper to check if any notices exist
  def any_notices?
    flash[:notice].present?
  end
end
