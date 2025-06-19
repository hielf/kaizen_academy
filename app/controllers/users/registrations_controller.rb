class Users::RegistrationsController < Devise::RegistrationsController
  # Skip Pundit authorization for Devise registrations
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @schools = School.where(status: 'active').order(:name)
    super
  end

  # POST /resource
  def create
    # Set the type to 'Student' for new registrations
    params[:user][:type] = 'Student'
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :school_id, :type])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :school_id])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end 