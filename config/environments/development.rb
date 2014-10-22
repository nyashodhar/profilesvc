Rails.application.configure do

  # Settings specified here will take precedence over those in config/application.rb.

  # Base URL for downstream auth service
  config.authsvc_base_url = "https://authpetpalci.herokuapp.com"

  # Redis
  config.redis_host = "localhost"
  config.redis_port = "6379"

  #
  # Setting this to true means:
  #
  #   1) redis.conf has a password specified, e.g.
  #
  #         masterauth test123
  #
  #   2) The slaves are required to provide a password
  #      when connecting to the master, e.g. in redis.conf:
  #
  #         requirepass test123
  #
  config.redis_password_required = false
  config.redis_password = "test123"

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  #Logger Config
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new('log/profilesvc-dev.log', 'daily'))
  config.log_level = :info

end
