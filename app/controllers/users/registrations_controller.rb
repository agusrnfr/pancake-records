class Users::RegistrationsController < Devise::RegistrationsController
  layout "backoffice"
  
  before_action :configure_account_update_params, only: [:update]

  def edit
    super
  end

  def update
    super
  end

  protected

  def after_update_path_for(resource)
    backoffice_root_path
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:password, :password_confirmation, :current_password, :name, :surname, :address, :avatar])
  end
end
