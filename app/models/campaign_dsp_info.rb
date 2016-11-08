class CampaignDspInfo < ActiveRecord::Base
  belongs_to :campaign

  scope :dsp_info, -> (campaign) { select('IFNULL(SUM(clicks),0) AS clicks, IFNULL(SUM(impressions),0) AS views').where('campaign_id = ? and date > ? and date < ?',campaign.id, campaign.start_time.to_date, campaign.end_time.to_date) }

  scope :sum_daily_record, -> (campaign, end_time = nil) {
    if end_time.nil?
      select('IFNULL(SUM(clicks),0) AS clicks, IFNULL(SUM(impressions),0) AS views').where(campaign_id: campaign.id).first
    else
      select('IFNULL(SUM(clicks),0) AS clicks, IFNULL(SUM(impressions),0) AS views').where(campaign_id: campaign.id, date: campaign.start_time.to_date..end_time).first
    end
  }
end
