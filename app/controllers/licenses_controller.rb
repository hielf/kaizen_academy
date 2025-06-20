class LicensesController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :authenticate_user!

  def redeem
    license_code = params[:license_code].to_s.upcase.strip
    @term = Term.find(params[:term_id])
    license = @term.licenses.find_by(code: license_code)

    if license.nil?
      @error_message = "Invalid license code for this term."
    else
      authorize license, :redeem?
      unless license.redeem!(current_user)
        @error_message = license.errors.full_messages.first || "Failed to redeem license. Please contact support."
      end
    end

    respond_to do |format|
      if @error_message
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("redeem_feedback", partial: "shared/alert", locals: { alert: @error_message })
        end
      else
        format.html { redirect_to @term, notice: "License redeemed successfully. You are now subscribed to this term." }
      end
    end
  rescue Pundit::NotAuthorizedError
    @error_message = "This license is not active, has expired, or has already been redeemed."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("redeem_feedback", partial: "shared/alert", locals: { alert: @error_message })
      end
    end
  end
end
