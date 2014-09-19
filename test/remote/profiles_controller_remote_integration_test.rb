require 'test_helper'

class ProfilesControllerRemoteIntegrationTest < RemoteIntegrationTest

  include ProfilesControllerTests

  #
  # GET /profile
  #

  test "GET Profile - API is protected by auth filter" do
    check_api_is_protected("GET", "profile", nil)
  end

  test "GET Profile - Verify profile can be looked up after fields set individually" do
    check_profile_can_looked_up_after_fields_set_individually
  end

  #
  # POST /profile
  #

  test "POST profile - API is protected by auth filter" do
    # NOTE: The body is not important here, just needs to be an example request
    check_api_is_protected("POST", "profile", {:first_name => 'Frank'}.to_json)
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
    check_api_is_protected("PUT", "profile", { :first_name => 'Frank'}.to_json)
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

end