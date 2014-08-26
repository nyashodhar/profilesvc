require 'test_helper'

class ProfilesControllerIntegrationTest < ActionDispatch::IntegrationTest

  test "Update first name of profile" do

    profile_name_update_body = { :firstname => 'Frank'}.to_json
    profile_update_headers = create_post_headers_with_auth_token('GOOD')

    # Check that this API call is protected by the auth filter
    check_api_is_protected("POST", "profile", profile_name_update_body, profile_update_headers)

    # Check that this API gives a 201 response when trying to POST the firstname in the profile
    post "profile", profile_name_update_body, profile_update_headers
    assert_response :created
    the_response = JSON.parse(response.body)
    assert_not_nil(the_response["status"])
    assert(the_response["status"].eql?("updated"))
  end

end