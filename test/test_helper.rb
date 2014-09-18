ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock'
include WebMock::API
require 'rest-client'

require 'fixtures/auth/auth_service_credentials_util'
require 'helpers/auth_service_mock_helper'
require 'helpers/auth_service_real_helper'
require 'helpers/rest_client_util'
require 'integration/hybrid_integration_test'
require 'controllers/application_controller_tests'
require 'controllers/deployments_controller_tests'
require 'controllers/profiles_controller_tests'
require 'middleware/catch_json_parse_errors_tests'

class ActiveSupport::TestCase

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
end
