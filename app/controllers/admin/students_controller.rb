class Admin::StudentsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_student, only: [:show, :destroy]

  def index
    @students = Student.includes(:school).order(:email)
    
    if params[:name_filter].present?
      @students = @students.where("email LIKE ? OR first_name LIKE ? OR last_name LIKE ?", 
                                 "%#{params[:name_filter]}%", 
                                 "%#{params[:name_filter]}%", 
                                 "%#{params[:name_filter]}%")
    end
    
    if params[:school_filter].present?
      @students = @students.joins(:school).where("schools.name LIKE ?", "%#{params[:school_filter]}%")
    end
  end

  def show
  end

  def destroy
    if @student.destroy
      redirect_to admin_students_path, notice: 'Student was successfully deleted.'
    else
      redirect_to admin_student_path(@student), alert: 'Failed to delete student.'
    end
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end
end 