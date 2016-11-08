class DataTrackingController < ApplicationController
  def index
    @campaign = Campaign.find(params[:campaign_id])
    @data = current_user.is_admin? ? @campaign.campaign_dsp_infos.order(:date) : []
    @daily_trackings = @campaign.daily_tracking_records.group_by{|r| r.date}
    @actual_clicks = @campaign.daily_tracking_records.sum(:clicks)
    @actual_views = @campaign.daily_tracking_records.sum(:views)
  end

  def tracking
    @date = params[:date_tracking].present? ? params[:date_tracking][:date].to_date : Date.today
    @campaigns =  Campaign.active_campaigns(Date.today)
    @data = []
    @total = {}

    @campaigns.each do |c|
      sum_mongo_daily = MongoDb::DailyStat.where(campaign_id: c.id, timestamp: {:$eq => @date.beginning_of_day})

      mongo_views = sum_mongo_daily.sum(:views)
      mongo_click = sum_mongo_daily.sum(:clicks)

      bidstalk_data = c.campaign_dsp_infos.where(date: @date)
      views = bidstalk_data.sum(:impressions)
      clicks = bidstalk_data.sum(:clicks)

      discrepancy_views = get_discrepancy(mongo_views.to_f, views)
      discrepancy_clicks = get_discrepancy(mongo_click.to_f, clicks)

      @data << {
                id: c.id,
                name: c.name,
                status: c.status,
                mongo_views: mongo_views,
                mongo_clicks: mongo_click,
                bidstalk_views: views,
                bidstalk_clicks: clicks,
                discrepancy_clicks: discrepancy_clicks,
                discrepancy_views: discrepancy_views
              }
    end
    @total[:mongo_views] = @data.inject(0){ |sum,e| sum += e[:mongo_views] }
    @total[:mongo_clicks] = @data.inject(0){ |sum,e| sum += e[:mongo_clicks] }
    @total[:bidstalk_views] = @data.inject(0){ |sum,e| sum += e[:bidstalk_views] }
    @total[:bidstalk_clicks] = @data.inject(0){ |sum,e| sum += e[:bidstalk_clicks] }
    @total[:discrepancy_views] = get_discrepancy(@total[:mongo_views].to_f, @total[:bidstalk_views])
    @total[:discrepancy_clicks] = get_discrepancy(@total[:mongo_clicks].to_f, @total[:bidstalk_clicks])
  end

  private

  def get_discrepancy(mongo, bidstalk)
    result = (mongo - bidstalk).to_f * 100 / bidstalk
    return 100.0 if result.infinite?
    return 0.0 if result.nan?
    result.round(2)
  end
end