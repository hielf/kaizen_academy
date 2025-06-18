class HomeController < ApplicationController
  def index
    if user_signed_in? && current_user.admin?
      @schools = School.all.order(:name)
    end
  end
end 