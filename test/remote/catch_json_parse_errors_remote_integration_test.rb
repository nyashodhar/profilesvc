class CatchJsonParseErrorsRemoteIntegrationTest < HybridIntegrationTest

  include CatchJsonParseErrorsTests

  setup do
    WebMock.allow_net_connect!
    @remote_test = true
    @mock_auth_service = false
  end

  test "Verify invalid JSON handling" do
    check_invalid_json_handling
  end

end