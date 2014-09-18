#######################################################
#
# Utility class that provides URL for a remotely running
# profile service app to connect to during remote
# integration tests
#
#######################################################

class ServiceURLUtil

  def initialize
    config_file = "#{Rails.root}/test/fixtures/config/service_url.yml"
    service_url_yaml = YAML::load_file(config_file)
    the_environment = Rails.env.to_str
    @service_url_for_env = service_url_yaml[the_environment]
    STDOUT.write "=> ServiceURLUtil: Service URLs loaded from #{config_file}\n"
  end

  def get_profile_service_url
    return @service_url_for_env['profile_service_url']
  end

  def get_auth_service_url
    return @service_url_for_env['auth_service_url']
  end

end