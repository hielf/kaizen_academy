class HomeController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    if user_signed_in?
      if current_user.admin?
        # @schools = policy_scope(School).order(:name)
        @schools = School.all.order(:name)
      elsif current_user.student?
        load_student_dashboard_data
      end
    end
  end

  private

  def load_student_dashboard_data
    @student = current_user
    @school = policy_scope(School).find(@student.school_id) if @student.school_id
    subscribed_term_ids = @student.term_subscriptions.pluck(:term_id)
    @terms = policy_scope(@school.terms).where("end_date >= ?", Date.current).where.not(id: subscribed_term_ids).order(:start_date) if @school
    @courses = policy_scope(@school.courses).joins(:term).where("terms.end_date >= ?", Date.current).where.not(id: @student.course_ids).includes(:term).order(:start_date, :title) if @school
    @enrollments = @student.enrollments.includes(:course, course: :term).order(created_at: :desc)
  end
end
