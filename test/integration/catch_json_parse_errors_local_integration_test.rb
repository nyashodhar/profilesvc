require 'test_helper'

class CatchJsonParseErrorsLocalIntegrationTest < HybridIntegrationTest

  include CatchJsonParseErrorsTests

  test "Verify invalid JSON handling" do
    check_invalid_json_handling
  end
end