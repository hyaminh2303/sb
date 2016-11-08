# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# RAILS_ENV=production bundle exec whenever --update-cron --set 'frequency=60&environment=staging'
set :output, "log/cron_log.log"
env :PATH, ENV['PATH']
set :environment, @environment

#frequent is in seconds
every @frequency.to_i do
  runner 'AdsRequestWorker.perform_async'
end

every 5.minutes do
  runner 'BidstalkSyncWorker.perform_async'
  runner 'BidOptimizationWorker.perform_async'
end

# run daily tasks
# every 1.day, :at => '12:30 am' do
#   runner 'BidOptimizationWorker.perform_async'
# end

every 1.day, :at => '12:45 am' do
  runner 'DailyCampaignWorker.perform_async'
  runner 'DailyCampaignOptWorker.perform_async'
end
