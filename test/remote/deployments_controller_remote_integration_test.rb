require 'test_helper'

class DeploymentsControllerRemoteIntegrationTest < HybridIntegrationTest

  include DeploymentsControllerTests

  setup do
    WebMock.allow_net_connect!
    @remote_test = true
    @mock_auth_service = false
  end

  test "Check 204 for status request" do
    check_204_for_status_request
  end
end
