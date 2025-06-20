class TermsController < ApplicationController
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized
  before_action :authenticate_user!
  before_action :set_term, only: [ :show ]

  def show
    authorize @term
    @courses = policy_scope(@term.courses).order(:title)
  end

  private

  def set_term
    @term = Term.joins(:school).where(schools: { id: current_user.school_id }).find(params[:id])
  end
end
