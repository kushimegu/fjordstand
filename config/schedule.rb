require File.expand_path(File.dirname(__FILE__) + "/environment")
rails_env = ENV['RAILS_ENV'] || :development
set :environment, rails_env
set :output, "#{Rails.root}/log/crontab.log"

job_type :rake, "export PATH=\"$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH\"; eval \"$(rbenv init -)\"; cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"
set :job_template, "/bin/zsh -c ':job'"

every 1.day, at: '8:00 am' do
  rake "lottery:select_winner"
end
