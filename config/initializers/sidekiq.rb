REDIS_URL = 'redis://'
REDIS_URL += ":#{APP_CONFIG['redis']['tracking']['password']}@" if APP_CONFIG['redis']['tracking']['password'].present?
REDIS_URL += "#{APP_CONFIG['redis']['tracking']['host']}:#{APP_CONFIG['redis']['tracking']['port']}"

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URL }
end

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URL }
end