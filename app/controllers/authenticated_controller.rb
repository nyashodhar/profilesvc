class AuthenticatedController < ActionController::Base

  include AuthenticationHelper

  #
  # Note: This filter will do a downstream request to the auth service to
  # check that there is a sign-in for the auth token, and that the sign-in
  # is not expired
  #
  before_action :ensureAuthorized

  private

  #
  # Note: This method is used to pass the value of the user id of a user
  # that has been authenticated from the authentication filter to the
  # controller's action. This allows access to the user id from within
  # the action in the controller once the filter processing is done.
  #
  def set_authenticated_user_id(authenticated_user_id)
    @authenticated_user_id = authenticated_user_id
  end

end