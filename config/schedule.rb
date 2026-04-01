require File.expand_path(File.dirname(__FILE__) + "/environment")
rails_env = ENV['RAILS_ENV'] || :development
set :environment, rails_env

if rails_env == :production
  set :output, { standard: '/proc/1/fd/1', error: '/proc/1/fd/2' }
  job_type :rake, "/rails/bin/cron_executor bundle exec rake :task :output"
  set :job_template, "/usr/bin/bash -l -c ':job'"
else
  set :output, "#{Rails.root}/log/crontab.log"
  job_type :rake, "export PATH=\"$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH\"; eval \"$(rbenv init -)\"; cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"
  set :job_template, "/bin/zsh -c ':job'"
end

every 1.day, at: '8:00 am' do
  rake "lottery:select_winner"
end

every 1.minute do
  rake "test:log"
end
