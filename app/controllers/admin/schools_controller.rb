class Admin::SchoolsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_school, only: [:show, :edit, :update, :destroy]

  def index
    @schools = policy_scope(School).order(:name)
    
    if params[:name_filter].present?
      @schools = @schools.where("name LIKE ?", "%#{params[:name_filter]}%")
    end
  end

  def show
    authorize @school
  end

  def new
    @school = School.new
    authorize @school
  end

  def edit
    authorize @school
  end

  def create
    @school = School.new(school_params)
    authorize @school

    if @school.save
      redirect_to admin_school_path(@school), notice: 'School was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @school
    if @school.update(school_params)
      redirect_to admin_school_path(@school), notice: 'School was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @school
    @school.destroy
    redirect_to admin_schools_path, notice: 'School was successfully deleted.'
  end

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:name)
  end
end 