class Admin::LicensesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_school
  before_action :set_term
  before_action :set_license, only: [ :show, :edit, :update, :destroy ]

  def index
    @licenses = policy_scope(@term.licenses)
  end

  def show
    authorize @license
  end

  def new
    @license = @term.licenses.build
    authorize @license
  end

  def create
    @license = @term.licenses.build(license_params)
    @license.issued_at = Time.zone.now
    @license.expires_at = @term.end_date.end_of_day
    authorize @license

    if @license.save
      redirect_to admin_school_term_license_path(@school, @term, @license), notice: "License was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def generate
    @license = @term.licenses.build
    @license.issued_at = Time.zone.now
    @license.expires_at = 1.year.from_now
    authorize @license, :generate?

    if @license.save
      redirect_to admin_school_term_path(@school, @term), notice: "License #{@license.code} was successfully generated."
    else
      redirect_to admin_school_term_path(@school, @term), alert: "Failed to generate license."
    end
  end

  def edit
    authorize @license
  end

  def update
    authorize @license
    if @license.update(license_params)
      redirect_to admin_school_term_license_path(@school, @term, @license), notice: "License was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @license
    if @license.destroy
      redirect_to admin_school_term_path(@school, @term), notice: "License was successfully deleted."
    else
      redirect_to admin_school_term_path(@school, @term), alert: @license.errors.full_messages.join(", ")
    end
  end

  private

  def set_school
    @school = School.find(params[:school_id])
    # authorize @school
  end

  def set_term
    @term = @school.terms.find(params[:term_id])
    # authorize @term
  end

  def set_license
    @license = @term.licenses.find(params[:id])
  end

  def license_params
    params.require(:license).permit(:code, :status)
  end
end
