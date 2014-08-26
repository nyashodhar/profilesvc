########################################################
#
# This module provides functionality to test the auth
# filtering functionality for a given API call.
#
# The testing of the auth filter relies on mocking the
# the behavior of the auth service.
#
########################################################
module AuthServiceMockHelper

  ##########################################################
  #
  # Performs all the testing needed to verify that the
  # auth filter protection is applied correctly for the
  # API specified.
  #
  ##########################################################
  def check_api_is_protected(http_method, api_uri, request_body, request_headers)

    validate_http_method(http_method)

    my_headers = request_headers.clone

    auth_mock_normal

    #
    # Do checking to check 401 is given under normal circumstances
    #

    # If auth token is missing, the filter should give a 401..
    my_headers.delete('X-User-Token')
    exercise_api(http_method, api_uri, request_body, my_headers)
    assert_response :unauthorized

    # If auth token is bad, there should be a downstream 401 and the filter should pass on the 401
    my_headers['X-User-Token'] = "BAD"
    exercise_api(http_method, api_uri, request_body, my_headers)
    assert_response :unauthorized

    #
    # Do checking to check the filter is giving 500 error if the
    # auth service is not behaving as expected..
    #

    # If the filter got 200 response from auth service that didn't echo the auth token,
    # then the filter should give 500 response
    auth_mock_good_gives_200_response_missing_token
    my_headers['X-User-Token'] = "GOOD"
    exercise_api(http_method, api_uri, request_body, my_headers)
    assert_response :internal_server_error

    # If the filter got a 500 error from auth service, then the filter should give a 500 response
    auth_mock_good_gives_500_response
    my_headers['X-User-Token'] = "GOOD"
    exercise_api(http_method, api_uri, request_body, my_headers)
    assert_response :internal_server_error

    # Leave the mocking in a normal state...
    auth_mock_normal

    STDOUT.write "Good news: The API \'#{http_method} #{api_uri}\' passed auth tests.\n"
  end

  ###########################################################################
  #
  # Register mock behavior to trigger 'Normal' auth service behavior
  #
  # While this behavior is registered, do all the testing of the authfilter
  # where normal auth service behavior is expected
  #
  ###########################################################################
  def auth_mock_normal

    auth_svc_base_url = Rails.application.config.authsvc_base_url
    auth_url = "#{auth_svc_base_url}/user/auth"

    #
    # Mock the successful auth service response
    # 200 - and the response echoes the auth token in JSON
    #
    auth_request_good_headers = {'Content-Type' => 'application/json', 'X-User-Token' => 'GOOD', 'Accept' => 'application/json'}
    auth_success_response = { :id => '1', :email => 'integration@test.com', :authentication_token => 'GOOD'}.to_json

    stub_request(:get, auth_url).with(:headers => auth_request_good_headers).to_return {
        |request| {:status => 200, :body => auth_success_response}
    }

    #
    # Mock the  auth service response
    # 401 Not authorized
    #
    auth_request_bad_headers = {'Content-Type' => 'application/json', 'X-User-Token' => 'BAD', 'Accept' => 'application/json'}
    auth_failure_response = {:error => I18n.t("401response")}.to_json

    stub_request(:get, auth_url).with(:headers => auth_request_bad_headers).to_return {
        |request| {:status => 401, :body => auth_failure_response}
    }
  end


  ###########################################################################
  #
  # Register an abnormal mock service behavior where the 200 response
  # is not echoing the user's auth token. This should trigger a 500 response
  # from our authentication filter.
  #
  ###########################################################################
  def auth_mock_good_gives_200_response_missing_token

    auth_svc_base_url = Rails.application.config.authsvc_base_url
    auth_url = "#{auth_svc_base_url}/user/auth"

    #
    # Mock the successful auth service response
    # 200 - BUT the response does not echoe the auth token in JSON
    #
    auth_request_good_headers = {'Content-Type' => 'application/json', 'X-User-Token' => 'GOOD', 'Accept' => 'application/json'}
    auth_success_response = { :id => '1', :email => 'integration@test.com', :authentication_token => 'GOODPlusStuff'}.to_json

    stub_request(:get, auth_url).with(:headers => auth_request_good_headers).to_return {
        |request| {:status => 200, :body => auth_success_response}
    }
  end

  ###########################################################################
  #
  # Register an abnormal mock service behavior where the auth service gives
  # a 500 response. This should a 500 response from our authentication filter.
  #
  ###########################################################################
  def auth_mock_good_gives_500_response

    auth_svc_base_url = Rails.application.config.authsvc_base_url
    auth_url = "#{auth_svc_base_url}/user/auth"

    #
    # Mock the successful auth service response
    # 200 - BUT the response does not echoe the auth token in JSON
    #
    auth_request_good_headers = {'Content-Type' => 'application/json', 'X-User-Token' => 'GOOD', 'Accept' => 'application/json'}
    auth_500_response = {:error => I18n.t("500response_internal_server_error")}.to_json

    stub_request(:get, auth_url).with(:headers => auth_request_good_headers).to_return {
        |request| {:status => 200, :body => auth_500_response}
    }
  end

  def validate_http_method(http_method)
    if(http_method.blank?)
      raise 'Parameter http_method not specified'
    end

    if(!(http_method.eql?('GET') || http_method.eql?('POST') || http_method.eql?('PUT')))
      raise 'Invalid value #{http_method} for http_method.'
    end
  end

  def exercise_api(http_method, api_uri, request_body, my_headers)
    if(http_method.eql?("POST"))
      post api_uri, request_body, my_headers
    end

    if(http_method.eql?("PUT"))
      post api_uri, request_body, my_headers
    end

    if(http_method.eql?("GET"))
      get api_uri, nil, my_headers
    end
  end

  #########################################
  # Create a hash containing the headers
  # to be used in a POST request
  #########################################
  def create_post_headers_with_auth_token(auth_token)
    validate_auth_token(auth_token)
    return { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json', 'X-User-Token' => auth_token}
  end

  def validate_auth_token(auth_token)
    if(auth_token.blank?)
      raise 'Parameter auth_token not specified'
    end

    if(auth_token.eql?('GOOD') && auth_token.eql?('BAD'))
      raise 'Invalid value #{auth_token} for auth_token. Value must be either \'GOOD\' or \'BAD\''
    end
  end

end