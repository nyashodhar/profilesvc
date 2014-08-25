require 'test_helper'

class CatchJsonParseErrorsIntegrationTest  < ActionDispatch::IntegrationTest

  #
  # Test that requests with invalid json are handled properly
  # Send a request with invalid JSON, you should get a 400 JSON response
  #
  test "Verify invalid JSON handling" do
    invalid_json = '{ not good json'
    headers = { 'CONTENT_TYPE' => 'application/json' }
    post "profile", invalid_json, headers
    assert_response :bad_request

    the_response = JSON.parse(response.body)
    assert_not_nil(the_response["error"])
    assert(the_response["error"].eql?("There was a problem in your JSON"))
  end

end