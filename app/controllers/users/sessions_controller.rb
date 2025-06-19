class Users::SessionsController < Devise::SessionsController
  # Skip Pundit authorization for Devise sessions
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # The path used after sign in.
  def after_sign_in_path_for(resource)
    super(resource)
  end

  # The path used after sign out.
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end 