class Admin::CoursesController < ApplicationController
  before_action :set_school
  before_action :set_term
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  def index
    @courses = @term.courses
  end

  def show
  end

  def new
    @course = @term.courses.build
  end

  def create
    @course = @term.courses.build(course_params)
    @course.school = @school  # Explicitly set the school association

    if @course.save
      redirect_to admin_school_term_course_path(@school, @term, @course), notice: 'Course was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to admin_school_term_course_path(@school, @term, @course), notice: 'Course was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to admin_school_term_courses_path(@school, @term), notice: 'Course was successfully deleted.'
  end

  private

  def set_school
    @school = School.find(params[:school_id])
  end

  def set_term
    @term = @school.terms.find(params[:term_id])
  end

  def set_course
    @course = @term.courses.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description)
  end
end 