class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Pundit configuration
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_admin!
    unless user_signed_in? && current_user&.is_a?(Admin)
      flash[:alert] = "You must be an admin to access this page."
      redirect_to root_path
    end
  end

  def user_not_authorized
    # Skip error handling for Devise controllers
    return if devise_controller?

    flash[:alert] = "You are not authorized to perform this action."
    if request.referer && request.referer != request.url
      redirect_back(fallback_location: root_path)
    else
      redirect_to root_path
    end
  end
end
