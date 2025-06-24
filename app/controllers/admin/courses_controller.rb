class Admin::CoursesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_school
  before_action :set_term
  before_action :set_course, only: [ :show, :edit, :update, :destroy ]

  def index
    @courses = policy_scope(@term.courses)
  end

  def show
    authorize @course
  end

  def new
    @course = @term.courses.build
    authorize @course
  end

  def create
    @course = @term.courses.build(course_params)
    @course.school = @school  # Explicitly set the school association
    authorize @course

    if @course.save
      redirect_to admin_school_term_course_path(@school, @term, @course), notice: "Course was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course
  end

  def update
    authorize @course
    if @course.update(course_params)
      redirect_to admin_school_term_course_path(@school, @term, @course), notice: "Course was successfully updated."
    else
      flash.now[:alert] = @course.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    if @course.destroy
      redirect_to admin_school_term_courses_path(@school, @term), notice: "Course was successfully deleted."
    else
      redirect_to admin_school_term_course_path(@school, @term, @course), alert: @course.errors.full_messages.join(", ")
    end
  end

  private

  def set_school
    @school = School.find(params[:school_id])
    authorize @school
  end

  def set_term
    @term = @school.terms.find(params[:term_id])
    authorize @term
  end

  def set_course
    @course = @term.courses.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :price, :description)
  end
end
