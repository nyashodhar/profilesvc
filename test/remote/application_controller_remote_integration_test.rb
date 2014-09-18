require 'test_helper'

class ApplicationControllerRemoteIntegrationTest < HybridIntegrationTest

  include ApplicationControllerTests

  setup do
    WebMock.allow_net_connect!
    @remote_test = true
    @mock_auth_service = false
  end

  test "Verify 404 response for URL with no mapping - Always JSON response" do
    check_404_for_url_with_no_mapping
  end

end

