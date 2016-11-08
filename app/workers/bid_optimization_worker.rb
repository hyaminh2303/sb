class BidOptimizationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    run_at = Time.now
    today_date =  Date.today.to_date

    # sync
    CampaignDspDriver.new(today_date).sync_data_active_campaign

    active_campaigns = Campaign.published_campaigns.active_campaigns(today_date).optimization_campaigns
    active_campaigns.each do |campaign|
      begin
        next unless campaign.live? || campaign.paused?
        optimizer = CampaignOptimization.new(campaign)
        optimizer.optimize_over_delivery
        optimizer.optimize_over_budget
      rescue StandardError => e
        WorkerMailer.error_worker("#{self.class.name}: pause", run_at, e, campaign).deliver if $allow_send_message
        $allow_send_message = false
      end
    end
  end
end