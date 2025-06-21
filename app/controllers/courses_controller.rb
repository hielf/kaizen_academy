class CoursesController < ApplicationController
  before_action :set_course, only: [:show]
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def show
    authorize @course
    @school = @course.school
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end
end 