class ProfilesController < ActionController::Base

  include ApplicationHelper

  #
  # Note: This filter will do a downstream request to the auth service to
  # check that there is a sign-in for the auth token, and that the sign-in
  # is not expired
  #
  before_action :ensureAuthorized

  ####################################################
  # Create or update profile
  #
  # POST /profile
  #
  # - 401 if not authenticated
  # - 400 if request has a problem
  # - 201 if request was processed successfully
  #
  # EXAMPLE:
  #
  # curl -v -X POST http://127.0.0.1:3000/profile -H "Accept: application/json" -H "Content-Type: application/json" -H "X-User-Token: a6XK1qPfwyNd_HqjsgSS" -d '{"firstname":"Frank"}'
  ####################################################
  def createOrUpdate
    logger.info "Hello there"
    render :status => 201, :json => "Hello there"
  end
end
