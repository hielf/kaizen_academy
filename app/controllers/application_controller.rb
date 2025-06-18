class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def authenticate_admin!
    unless current_user&.is_a?(Admin)
      flash[:alert] = "You must be an admin to access this page."
      redirect_to root_path
    end
  end
end
