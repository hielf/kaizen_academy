class Admin::TermsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_school
  before_action :set_term, only: [:show, :edit, :update, :destroy]

  def index
    @terms = @school.terms.order(start_date: :desc)
  end

  def show
  end

  def new
    @term = @school.terms.build
  end

  def edit
  end

  def create
    @term = @school.terms.build(term_params)

    if @term.save
      redirect_to admin_school_term_path(@school, @term), notice: 'Term was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @term.update(term_params)
      redirect_to admin_school_term_path(@school, @term), notice: 'Term was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @term.destroy
    redirect_to admin_school_terms_path(@school), notice: 'Term was successfully deleted.'
  end

  private

  def set_school
    @school = School.find(params[:school_id])
  end

  def set_term
    @term = @school.terms.find(params[:id])
  end

  def term_params
    params.require(:term).permit(:name, :start_date, :end_date)
  end
end 