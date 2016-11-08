class DailyCampaignOptWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  INCREASE_MAX_BIX_NUMBER = 0.05
  def perform
    run_at = Time.now
    action = 'Increase max bid'
    today_date = Date.today
    active_campaigns = Campaign.published_campaigns.active_campaigns(today_date).optimization_campaigns
    active_campaigns.each do |campaign|
      begin
        optimizer = CampaignOptimization.new(campaign)
        optimizer.optimize_pause_yesterday
        optimizer.optimize_under_delivery
      rescue StandardError => e
        WorkerMailer.error_worker("#{self.class.name}: #{action}", run_at, e, campaign).deliver
        raise e
      end
    end      
  end
end