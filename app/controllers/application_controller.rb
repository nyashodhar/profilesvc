class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def not_found
    logger.error "Custom 404 Handler: No route found for path #{request.path}"
    render :status => 404, :json => {:error => I18n.t("404response_resource_not_found")}.to_json
  end
end
