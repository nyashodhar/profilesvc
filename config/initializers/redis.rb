
redishost = Rails.application.config.redishost
redisport = Rails.application.config.redisport

begin
  $redis = Redis.new(:host => redishost, :port => redisport)
  ping_result = $redis.ping
  STDOUT.write "=> Redis initializer: Created redis client for #{redishost}:#{redisport} - Ping result (#{ping_result})\n"
rescue => e
  STDOUT.write "=> ERROR in Redis initializer: Error when creating redis client for #{redishost}:#{redisport} - Error: #{e.inspect}\n"
  exit
end