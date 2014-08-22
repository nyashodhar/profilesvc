require 'test_helper'

class ProfilesControllerIntegrationTest < ActionDispatch::IntegrationTest

  test "A quick test to try WebMock" do

    auth_svc_base_url = Rails.application.config.authsvc_base_url

    STDOUT.write "auth_svc_base_url = #{auth_svc_base_url}\n"

    STDOUT.write "Hello - stubbing\n"

    stub_http_request(:post, auth_svc_base_url).
        with(:body => {:data => {:a => '1', :b => 'five'}})

    STDOUT.write "Hello - do request\n"

    RestClient.post(auth_svc_base_url, "data[a]=1&data[b]=five",
        :content_type => 'application/x-www-form-urlencoded')
  end

end