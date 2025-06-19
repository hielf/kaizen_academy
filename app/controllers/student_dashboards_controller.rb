class StudentDashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def show
    @student = current_user
    @school = @student.school
    @terms = @school.terms.order(start_date: :desc) if @school
    @courses = @school.courses.includes(:term).order(:title) if @school
    @enrollments = @student.enrollments.includes(:course, course: :term).order(created_at: :desc)
  end

  private

  def ensure_student!
    unless current_user.student?
      redirect_to root_path, alert: 'Access denied. Students only.'
    end
  end
end 