require 'test_helper'

class ProfilesControllerIntegrationTest < ActionDispatch::IntegrationTest

  test "A quick test to try WebMock" do

    STDOUT.write "Hello - stubbing\n"

    stub_http_request(:post, "www.example.com").
        with(:body => {:data => {:a => '1', :b => 'five'}})

    STDOUT.write "Hello - do request\n"

    RestClient.post('www.example.com', "data[a]=1&data[b]=five",
                    :content_type => 'application/x-www-form-urlencoded')
  end

end