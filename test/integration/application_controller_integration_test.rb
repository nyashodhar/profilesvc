require 'test_helper'

class ApplicationControllerIntegrationTest < ActionDispatch::IntegrationTest

  #
  # Test that requests for which the URL path could not be mapped to any
  # controller get a proper 404 formatted response
  #
  test "Verify 404 response for URL with no mapping - Always JSON response" do

    # Do request as JSON client

    my_request_headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
    get "user/authfoobar", nil, my_request_headers
    assert_response :not_found
    assert(response.headers["Content-Type"].downcase.include?("application/json"))

    my_response = JSON.parse(response.body)
    assert_not_nil(my_response["error"])
    assert(my_response["error"].eql?("Resource not found"))

    # Do request as HTML client

    my_request_headers = {'Content-Type' => 'text/html'}
    get "user/authfoobar", nil, my_request_headers
    assert_response :not_found
    assert(response.headers["Content-Type"].downcase.include?("application/json"))

    my_response = JSON.parse(response.body)
    assert_not_nil(my_response["error"])
    assert(my_response["error"].eql?("Resource not found"))
  end

end