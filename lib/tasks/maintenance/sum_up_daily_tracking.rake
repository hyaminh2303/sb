namespace :maintenance do
  desc 'Sum-up all requests hourly from Redis and save to DailyTracking, location tracking table in MySQL'
  task sum_up_daily_tracking: :environment do
    DailyTrackingWorker.new.perform
  end
end