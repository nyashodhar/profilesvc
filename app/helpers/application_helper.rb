module ApplicationHelper

  ########################################################################
  # This method is in use ALL PROTECTED APIS.
  #
  # This method uses a downstream call to the auth service to verify that
  # that the user is logged in and that the auth token is not expired.
  #
  # If the user is not logged in, this method will give a 401 response
  # and control will not reach the protected controller action.
  #
  # If the user is logged in, but the auth token is expired, this method
  # will give a 401 response and control will not reach the protected
  # controller action.
  #
  # If the user is logged in and the auth token is not expired, this
  # method will allow control to be reach the controller action.
  ########################################################################
  def ensureAuthorized

    token = request.headers['X-User-Token']
    if(token.blank?)
      logger.error "ensureAuthorized(): No auth token found in request"
      render :status => 422, :json => {:error => I18n.t("422user_token_missing")}
      return
    end

    auth_svc_base_url = Rails.application.config.authsvc_base_url
    auth_url = "#{auth_svc_base_url}/user/auth"

    # Note: Without setting accept header here, we will get an XML response
    auth_request_headers = {'Content-Type' => 'application/json', 'X-User-Token' => token, 'Accept' => 'application/json'}

    logger.debug "ensureAuthorized(): Doing GET #{auth_url} (headers = #{auth_request_headers})"

    begin

      auth_service_response = RestClient.get(auth_url, auth_request_headers)
      auth_service_response_hash = JSON.parse(auth_service_response)

      if(auth_service_response_hash['authentication_token'].blank? || !auth_service_response_hash['authentication_token'].eql?(token))
        logger.error "ensureAuthorized(): Auth service gave success response but the user's token could not be found in the response. This should NEVER happen!. CODE: #{auth_service_response.code}, RESPONSE: #{auth_service_response} (auth_url = #{auth_url}, auth_request_headers = #{auth_request_headers})"
        render :status => 500, :json => {:error => I18n.t("500response_internal_server_error")}
        return
      end

      # SUCCESS - Control flow will now enter the controller's action
      logger.info "ensureAuthorized(): Auth service success. CODE: #{auth_service_response.code}, USERID: #{auth_service_response_hash['id']}"
      return

    rescue => e

      if(defined? e.response)
        if(e.response.code == 401)
          logger.error "ensureAuthorized(): Not authorized. CODE: #{e.response.code}, RESPONSE: #{e.response}"
          render :status => 401, :json => {:error => I18n.t("401response")}
          return
        end
        logger.error "ensureAuthorized(): Unexpected auth service response. CODE: #{e.response.code}, RESPONSE: #{e.response} (auth_url = #{auth_url}, auth_request_headers = #{auth_request_headers})"
        render :status => 500, :json => {:error => I18n.t("500response_internal_server_error")}
        return
      else
        logger.error "ensureAuthorized(): Unexpected error! auth_url = #{auth_url}, auth_request_headers = #{auth_request_headers}, error = #{e}"
        render :status => 500, :json => {:error => I18n.t("500response_internal_server_error")}
        return
      end

    end
 end

end
