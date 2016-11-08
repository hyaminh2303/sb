class AdsRequestWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'rollup'

  def perform(date = Time.zone.now)
    date = date.to_datetime
    CampaignDspDriver.new(date).sync_data_active_campaign
    extractor = Extractor.new(date)
    extractor.run

    adjust_data(date.to_date)
  end

  def adjust_data(date)
    campaigns = Campaign.active_campaigns(date).published_campaigns
    campaigns.each do |campaign|
      begin
      adjustment_campaign = CampaignDataAdjustment.new(date, campaign)
      adjustment_campaign.adjust_model_data
      rescue => ex
        Rails.logger.error ex.message
      end
    end
  end
end