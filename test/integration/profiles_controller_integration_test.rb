require 'test_helper'

class ProfilesControllerIntegrationTest < ActionDispatch::IntegrationTest

  #
  # GET /profile
  #

  test "GET Profile - API is protected by auth filter" do
    profile_lookup_headers = create_get_headers_with_auth_token('GOOD')
    check_api_is_protected("GET", "profile", nil, profile_lookup_headers)
  end

  test "GET Profile - Verify fields" do

    auth_mock_normal

    update_or_post_profile("POST", {:first_name => "Hank", :last_name => "Sank"})

    profile_lookup_headers = create_get_headers_with_auth_token('GOOD')

    get "profile", nil, profile_lookup_headers

    assert_response 200
    the_response = JSON.parse(response.body)

    assert_not_nil(the_response["first_name"])
    assert(the_response["first_name"].eql?("Hank"))
    assert_not_nil(the_response["last_name"])
    assert(the_response["last_name"].eql?("Sank"))
  end


  #
  # POST /profile
  #

  test "POST profile - API is protected by auth filter" do
    # NOTE: The body is not important here, just needs to be an example request
    profile_name_update_body = { :first_name => 'Frank'}.to_json
    profile_update_headers = create_post_headers_with_auth_token('GOOD')
    check_api_is_protected("POST", "profile", profile_name_update_body, profile_update_headers)
  end

  test "POST profile - Ensure first name max length is enforced" do
    profile_ensure_field_max_length_is_enforced("POST", :first_name, 256)
  end

  test "POST profile - Ensure first name must be a string" do
    profile_ensure_field_value_must_be_a_string("POST", :first_name)
  end

  test "POST profile  - Set first name of profile" do
    update_or_post_profile("POST", {:first_name => "Frank"})
  end

  test "POST profile - Ensure last name max length is enforced" do
    profile_ensure_field_max_length_is_enforced("POST", :last_name, 256)
  end

  test "POST profile - Ensure last name must be a string" do
    profile_ensure_field_value_must_be_a_string("POST", :last_name)
  end

  test "POST profile  - Set last name of profile" do
    update_or_post_profile("POST", {:last_name => "Von Pal"})
  end


  #
  # PUT /profile
  #

  test "PUT profile - API is protected by auth filter" do
    # NOTE: The body is not important here, just needs to be an example request
    profile_name_update_body = { :first_name => 'Frank'}.to_json
    profile_update_headers = create_post_headers_with_auth_token('GOOD')
    check_api_is_protected("PUT", "profile", profile_name_update_body, profile_update_headers)
  end

  test "PUT profile - Ensure first name max length is enforced" do
    profile_ensure_field_max_length_is_enforced("PUT", :first_name, 256)
  end

  test "PUT profile - Ensure first name must be a string" do
    profile_ensure_field_value_must_be_a_string("PUT", :first_name)
  end

  test "PUT profile  - Update first name of profile" do
    update_or_post_profile("PUT", {:first_name => "Frank"})
  end

  test "PUT profile - Ensure last name max length is enforced" do
    profile_ensure_field_max_length_is_enforced("PUT", :last_name, 256)
  end

  test "PUT profile - Ensure last name must be a string" do
    profile_ensure_field_value_must_be_a_string("PUT", :last_name)
  end

  test "PUT profile  - Update last name of profile" do
    update_or_post_profile("PUT", {:last_name => "Von Pal"})
  end

  private

  def profile_ensure_field_max_length_is_enforced(http_method, field_name, max_length)

    auth_mock_normal

    field_value = create_str_with_len(max_length+1)
    profile_name_update_body = { field_name => field_value}.to_json
    profile_update_headers = create_post_headers_with_auth_token('GOOD')

    # Check that this API gives a 422 response since the input is too long
    if(http_method.eql?("POST"))
      post "profile", profile_name_update_body, profile_update_headers
    else
      put "profile", profile_name_update_body, profile_update_headers
    end
    assert_response 422
    the_response = JSON.parse(response.body)
    assert_not_nil(the_response["error"])
    assert_equal(the_response["error"].first, "Field #{field_name} has invalid length")
  end

  def profile_ensure_field_value_must_be_a_string(http_method, field_name)

    auth_mock_normal

    field_value = 7
    profile_name_update_body = { field_name => field_value}.to_json
    profile_update_headers = create_post_headers_with_auth_token('GOOD')

    # Check that this API gives a 422 response since the field is not a string
    if(http_method.eql?("POST"))
      post "profile", profile_name_update_body, profile_update_headers
    else
      put "profile", profile_name_update_body, profile_update_headers
    end
    assert_response 422
    the_response = JSON.parse(response.body)
    assert_not_nil(the_response["error"])
    assert_equal(the_response["error"].first, "Field #{field_name} has invalid type")
  end

  def update_or_post_profile(http_method, field_hash)

    auth_mock_normal

    profile_name_update_body = field_hash.to_json
    profile_update_headers = create_post_headers_with_auth_token('GOOD')

    # Check that this API gives a 201 response and echoes the updated value
    if(http_method.eql?("POST"))
      post "profile", profile_name_update_body, profile_update_headers
    else
      put "profile", profile_name_update_body, profile_update_headers
    end
    assert_response :created
    the_response = JSON.parse(response.body)

    field_hash.keys do |field_name|
      assert_not_nil(the_response[field_name.to_s])
      expected_value = field_hash[field_name]
      assert(the_response[field_name.to_s].eql?(field_value))
    end

  end


  def create_str_with_len(length)
    my_string = ""
    length.times do ||
      my_string = "#{my_string}X"
    end
    return my_string
  end

end