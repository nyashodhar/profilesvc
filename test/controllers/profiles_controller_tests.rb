module ProfilesControllerTests

  def check_profile_can_looked_up_after_fields_set_individually
    # Create new profile
    update_or_post_profile("POST", {:first_name => "Hank", :last_name => "Reihe"})

    # Update profile
    update_or_post_profile("POST", {:last_name => "Sank"})

    profile_lookup_headers = create_headers_with_auth_token("GET", get_good_auth_token())
    response = do_get_with_headers("profile", profile_lookup_headers)

    # Validate response code
    assert_response_code(response, 200)

    # Validate response body
    body = JSON.parse(response.body)
    assert_equal(body["first_name"], "Hank")
    assert_equal(body["last_name"], "Sank")
  end


  def profile_ensure_field_max_length_is_enforced(http_method, field_name, max_length)
    field_value = create_str_with_len(max_length+1)
    profile_update_body = { field_name => field_value}.to_json
    good_auth_token = get_good_auth_token

    # Check that this API gives a 422 response since the input is too long
    if(http_method.eql?("POST"))
      profile_update_headers = create_headers_with_auth_token("POST", good_auth_token)
      response = do_post_with_headers("profile", profile_update_body, profile_update_headers)
    else
      profile_update_headers = create_headers_with_auth_token("PUT", good_auth_token)
      response = do_put_with_headers("profile", profile_update_body, profile_update_headers)
    end

    assert_response_code(response, 422)
    the_response = JSON.parse(response.body)
    assert_not_nil(the_response["error"])

    error_hash = the_response["error"]
    assert_equal(["Input is too long"], error_hash[field_name.to_s])
  end

  def update_or_post_profile(http_method, field_hash)
    profile_update_body = field_hash.to_json
    good_auth_token = get_good_auth_token

    # Check that this API gives a 201 response and echoes the updated value
    if(http_method.eql?("POST"))
      profile_update_headers = create_headers_with_auth_token("POST", good_auth_token)
      response = do_post_with_headers("profile", profile_update_body, profile_update_headers)
    else
      profile_update_headers = create_headers_with_auth_token("PUT", good_auth_token)
      response = do_put_with_headers("profile", profile_update_body, profile_update_headers)
    end

    assert_response_code(response, 201)

    the_response = JSON.parse(response.body)

    field_hash.keys.each do |field_name|
      assert_not_nil(the_response[field_name.to_s])
      expected_value = field_hash[field_name]
      assert(the_response[field_name.to_s].eql?(expected_value))
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