
include AuthServiceMockHelper
include RestClientUtil

class HybridIntegrationTest < ActionDispatch::IntegrationTest

  setup do

    @remote_test = false

    if(Rails.application.config.mock_auth_svc_in_tests)
      @mock_auth_service = true
      WebMock.disable_net_connect!
      auth_mock_normal
    else
      @mock_auth_service = false
      WebMock.allow_net_connect!
    end

    #
    # TODO: Find better way to obtain URL to service under test
    #
    # This is the URL used when running remote integration tests
    # against a remote system.
    #
    @my_svc_url = "http://127.0.0.1:3000"
  end


  ##########################################################
  #
  # Performs all the testing needed to verify that the
  # auth filter protection is applied correctly for the
  # API specified.
  #
  ##########################################################
  def check_api_is_protected(http_method, api_uri, request_body)

    validate_http_method(http_method)

    my_headers = create_headers_with_auth_token(http_method, api_uri)

    #my_headers = request_headers.clone

    if(@mock_auth_service)
      auth_mock_normal
    end

    #
    # Do checking to check 401 is given under normal circumstances
    #

    # If auth token is missing, the filter should give a 401..
    my_headers.delete('X-User-Token')
    response = exercise_api(http_method, api_uri, request_body, my_headers)
    assert_response_code(response, 401)

    # If auth token is bad, there should be a downstream 401 and the filter should pass on the 401
    my_headers['X-User-Token'] = "BAD"
    response = exercise_api(http_method, api_uri, request_body, my_headers)
    assert_response_code(response, 401)

    if(@mock_auth_service)

      #
      # Do checking to check the filter is giving 500 error if the
      # auth service is not behaving as expected, this is only possible if the down
      # stream auth service is mocked..
      #

      # If the filter got 200 response from auth service that didn't echo the auth token,
      # then the filter should give 500 response
      auth_mock_good_gives_200_response_missing_token
      my_headers['X-User-Token'] = "GOOD"
      response = exercise_api(http_method, api_uri, request_body, my_headers)
      assert_response_code(response, 500)

      # If the filter got a 500 error from auth service, then the filter should give a 500 response
      auth_mock_good_gives_500_response
      my_headers['X-User-Token'] = "GOOD"
      response = exercise_api(http_method, api_uri, request_body, my_headers)
      assert_response_code(response, 500)

      # Leave the mocking in a normal state...
      auth_mock_normal
    end

    STDOUT.write "Good news: The API \'#{http_method} #{api_uri}\' passed auth tests.\n"
  end


  def exercise_api(http_method, api_uri, request_body, my_headers)

    if(http_method.eql?("POST"))
      #post api_uri, request_body, my_headers
      return do_post_with_headers(api_uri, request_body, my_headers)
    end

    if(http_method.eql?("PUT"))
      #post api_uri, request_body, my_headers
      return do_put_with_headers(api_uri, request_body, my_headers)
    end

    if(http_method.eql?("GET"))
      #get api_uri, nil, my_headers
      return do_get_with_headers(api_uri, my_headers)
    end
  end

  def create_headers(http_method)
    if(@remote_test)
      return create_headers_remote
    else
      return create_headers_local(http_method)
    end
  end

  def create_headers_with_auth_token(http_method, auth_token)
    if(@remote_test)
      return create_headers_with_auth_token_remote(auth_token)
    else
      return create_headers_with_auth_token_local(http_method, auth_token)
    end
  end

  def do_get_with_headers(api_uri, my_headers)
    if(@remote_test)
      return do_get_with_headers_remote(api_uri, my_headers)
    else
      get api_uri, nil, my_headers
      return response
    end
  end

  def do_post_with_headers(api_uri, my_body, my_headers)
    if(@remote_test)
      return do_post_with_headers_remote(api_uri, my_body, my_headers)
    else
      post api_uri, my_body, my_headers
      return response
    end
  end

  def do_put_with_headers(api_uri, my_body, my_headers)
    if(@remote_test)
      return do_put_with_headers_remote(api_uri, my_body, my_headers)
    else
      put api_uri, my_body, my_headers
      return response
    end
  end

  def get_good_auth_token
    if(!@mock_auth_service)
      return get_good_token_remote
    else
      return "GOOD"
    end
  end

  def assert_response_code(response, expected_response_code)
    if(@remote_test)
      assert_response_code_remote(response, expected_response_code)
    else
      assert_response expected_response_code
    end
  end

  def get_content_type(response)
    if(@remote_test)
      return get_content_type_remote(response)
    else
      return response.headers["Content-Type"]
    end
  end

  def create_headers_local(http_method)

    if(http_method.eql?("POST") || http_method.eql?("PUT"))
      return { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    end

    if(http_method.eql?("GET"))
      return {'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    end
  end

  def create_headers_with_auth_token_local(http_method, auth_token)

      if(http_method.eql?("POST") || http_method.eql?("PUT"))
        return { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json', 'X-User-Token' => auth_token }
      end

      if(http_method.eql?("GET"))
        return {'Content-Type' => 'application/json', 'Accept' => 'application/json', 'X-User-Token' => auth_token }
      end
  end

  ######################################################
  #
  # Obtain auth token from real auth service
  #
  ######################################################
  def get_good_token_remote

    email = "herrstrudel@gmail.com"
    password = "Test1234"

    auth_svc_base_url = Rails.application.config.authsvc_base_url
    auth_url = "#{auth_svc_base_url}/user/auth"
    auth_request_headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}

    login_user_hash = {:email => email, :password => password}
    login_body = {:user => login_user_hash}

    #STDOUT.write "get_token_from_login(): Doing GET #{auth_url} (headers = #{auth_request_headers}) - body #{login_body}\n"

    begin

      auth_service_response = RestClient.post(auth_url,login_body, auth_request_headers)
      auth_service_response_hash = JSON.parse(auth_service_response)

      if(auth_service_response_hash['authentication_token'].blank?)
        raise "get_token_from_login(): Auth service login gave success response but no token was found in the response. CODE: #{auth_service_response.code}, RESPONSE: #{auth_service_response} (auth_url = #{auth_url}, auth_request_headers = #{auth_request_headers}, login_body = #{login_body})"
      end

      #STDOUT.write "get_token_from_login(): Auth service login successful. CODE: #{auth_service_response.code}, USERID: #{auth_service_response_hash['id']}\n"
      return auth_service_response_hash['authentication_token']

    rescue => e

      if(defined? e.response)
        if(e.response.code == 401)
          raise "get_token_from_login(): Not authorized. CODE: #{e.response.code}, RESPONSE: #{e.response}"
        end
        raise "get_token_from_login(): Unexpected auth service response. CODE: #{e.response.code}, RESPONSE: #{e.response} (auth_url = #{auth_url}, auth_request_headers = #{auth_request_headers})"
      else
        raise "get_token_from_login(): Unexpected error! auth_url = #{auth_url}, auth_request_headers = #{auth_request_headers}, error = #{e}"
      end
    end
  end


  def validate_http_method(http_method)
    if(http_method.blank?)
      raise 'Parameter http_method not specified'
    end

    if(!(http_method.eql?('GET') || http_method.eql?('POST') || http_method.eql?('PUT')))
      raise 'Invalid value #{http_method} for http_method.'
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

  #########################################
  # Create a hash containing the headers
  # to be used in a GET request
  #########################################
  def create_get_headers_with_auth_token(auth_token)
    validate_auth_token(auth_token)
    return {'Content-Type' => 'application/json', 'Accept' => 'application/json', 'X-User-Token' => auth_token}
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