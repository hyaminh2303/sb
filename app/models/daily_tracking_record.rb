class DailyTrackingRecord < ActiveRecord::Base

  # region Associations

  belongs_to :banner
  belongs_to :order
  belongs_to :campaign

  serialize :devices, Array

  def banner
    Banner.unscoped { super }
  end
  # endregion

  scope :sum_daily_record, -> (campaign, end_time = nil) { 
    if end_time.nil?
      select('IFNULL(SUM(clicks),0) AS clicks, IFNULL(SUM(views),0) AS views').where(campaign_id: campaign.id).first
    else
      select('IFNULL(SUM(clicks),0) AS clicks, IFNULL(SUM(views),0) AS views').where(campaign_id: campaign.id, date: campaign.start_time.to_date..end_time).first
    end
  }

end