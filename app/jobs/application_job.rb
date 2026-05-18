class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  rescue_from(StandardError) do |exception|
    DiscordWebhook.new.notify_job_failure(self.class.name, exception.message)
    raise exception
  end
end
