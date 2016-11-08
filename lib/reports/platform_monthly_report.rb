class Reports::PlatformMonthlyReport
  attr_accessor :data

  def initialize
    @campaigns = Campaign.monthly_campaign
    # Get all sum by campaign & platform
    @daily = DailyTracking.monthly_campaign.sum_by_platform

    @data = map_platform do |daily_trackings|
      sub_data = daily_trackings.map do |d|
        Reports::Models::PlatformBreakdown.new platform: d.platform.name,
                                               campaign: d.campaign.name,
                                               views: d.views,
                                               clicks: d.clicks,
                                               spend: d.spend
      end

      data = Reports::Models::PlatformBreakdown.new platform: "#{daily_trackings.first.platform.name} Total",
                                                    campaign: nil, views: nil, clicks: nil, spend: nil,
                                                    data: sub_data
      data.sum(:views, :data)
      data.sum(:clicks, :data)
      data.sum(:spend, :data)
      data
    end
  end

  # # Campaign 1, Platform 1
  # # Campaign 1, Platform 2
  # # Campaign 2, Platform 1
  # # Campaign 2, Platform 1
  # def each_campaign(&block)
  #   @campaigns.each do |campaign|
  #     daily_trackings = @daily.where campaign_id: campaign.id
  #     if block_given?
  #       block.call campaign, daily_trackings
  #     else
  #       yield campaign, daily_trackings
  #     end
  #   end
  # end

  # Platform 1, Campaign 1
  # Platform 1, Campaign 2
  # Platform 2, Campaign 1
  # Platform 2, Campaign 2
  def map_platform
    platform_ids.map do |platform_id|
      daily_trackings = @daily.where platform_id: platform_id
      if block_given?
        yield(daily_trackings)
      end
    end.compact
  end

  private
  def platform_ids
    @daily.map {|d| d.platform_id}.to_set.to_a
  end
end
