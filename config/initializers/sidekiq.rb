# frozen_string_literal: true
url = ENV['REDIS_URL'] || "redis://127.0.0.1:6379"

Sidekiq.configure_server do |config|
  config.redis = { url: url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
end
