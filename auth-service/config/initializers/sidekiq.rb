redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6380/0")

Sidekiq.configure_server { |c| c.redis = { url: redis_url } }
Sidekiq.configure_client { |c| c.redis = { url: redis_url } }
