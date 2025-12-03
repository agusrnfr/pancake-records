require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
	before_action :set_browser

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to backoffice_root_path(current_user), alert: "No tenés permisos para realizar la acción seleccionada." }
      format.turbo_stream { redirect_to backoffice_root_path(current_user), status: :see_other, alert: "No tenés permisos para realizar la acción seleccionada." }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:surname, :name])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || backoffice_root_path
  end

	private

  def set_browser
    @browser = Browser.new(request.user_agent)
  end

end
