class PingJob
  include Sidekiq::Job

  def perform(msg = "hello")
    Rails.logger.info("[PingJob] #{msg}")
  end
end
