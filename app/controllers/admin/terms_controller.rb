class Admin::TermsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_school
  before_action :set_term, only: [ :show, :edit, :update, :destroy ]

  def index
    @terms = policy_scope(@school.terms).order(start_date: :desc)
  end

  def show
    authorize @term
  end

  def new
    @term = @school.terms.build
    authorize @term
  end

  def edit
    authorize @term
  end

  def create
    @term = @school.terms.build(term_params)
    authorize @term

    if @term.save
      redirect_to admin_school_term_path(@school, @term), notice: "Term was successfully created."
    else
      flash.now[:alert] = @term.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @term
    if @term.update(term_params)
      redirect_to admin_school_term_path(@school, @term), notice: "Term was successfully updated."
    else
      flash.now[:alert] = @term.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @term
    if @term.destroy
      redirect_to admin_school_terms_path(@school), notice: "Term was successfully deleted."
    else
      redirect_to admin_school_term_path(@school, @term), alert: @term.errors.full_messages.join(", ")
    end
  end

  private

  def set_school
    @school = School.find(params[:school_id])
    authorize @school
  end

  def set_term
    @term = @school.terms.find(params[:id])
  end

  def term_params
    params.require(:term).permit(:name, :start_date, :end_date)
  end
end
