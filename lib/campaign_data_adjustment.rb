class CampaignDataAdjustment
  TRACKING_MODELS = %w(daily_tracking location_tracking device_os_name carrier_name exchange_name app_name)

  ADJUSTMENT_TYPE = %w(views clicks)

  def initialize(date = nil, campaign)
    @date = (date || Date.today).to_date
    @campaign = campaign
    @daily_trackings = @campaign.daily_tracking_records.where(date: @date)
  end

  def adjust_model_data
    return unless ensure_data

    ADJUSTMENT_TYPE.each do |type|
      calculate_total_daily_tracking(type)
    end
    @campaign_dsp_info.save

    return if invalid_data?
    @campaign.update_dsp_views_clicks(@bidstalk_report)

    TRACKING_MODELS.each do |tracking_model_name|
      model = {
          daily_tracking: DailyTrackingRecord,
          location_tracking: LocationTrackingRecord,
          carrier_name: TrackingModels::CarrierTracking,
          device_os_name: TrackingModels::OsTracking,
          exchange_name: TrackingModels::Exchange,
          app_name: TrackingModels::AppTracking
      }[tracking_model_name.to_sym]
      ADJUSTMENT_TYPE.each do |type|
        next if total_discrepancy(type, model) <= 0
        adjust(model, type)
      end
    end
  end

  private

  def calculate_total_daily_tracking(type)
    @campaign_dsp_info.send("daily_tracking_#{type}=", @daily_trackings.sum(type.to_sym))
  end

  def adjust(model, type)
    number_record_of_model = tracking_record(model).count
    return if number_record_of_model == 0
    alpha = total_discrepancy(type, model) / number_record_of_model
    beta = total_discrepancy(type, model) % number_record_of_model
    tracking_record(model).find_each do |macro|
      break if alpha == 0
      macro.send("#{type}=", macro.send("#{type}") + alpha)
      macro.save(validate: false)
    end
    tracking_record(model).each_with_index do |macro, index|
      break if index == beta
      macro.send("#{type}=", macro.send("#{type}") + 1)
      macro.save(validate: false)
    end
  end

  def total_discrepancy(type, model)
    {
        clicks: @bidstalk_report[:clicks].to_i - model.where(campaign_id: @campaign.id, date: @campaign.start_time.to_date..@date).sum(:clicks),
        views: @bidstalk_report[:impressions].to_i - model.where(campaign_id: @campaign.id, date: @campaign.start_time.to_date..@date).sum(:views)
    }[type.to_sym]
  end

  def tracking_record(model)
    records = model.where(campaign_id: @campaign.id)
    records = records.where(date: @date).presence || records.where(date: @date - 1.day)
    records
  end

  def invalid_data?
    @bidstalk_report.include?('failed')
  end

  def ensure_data
    @bidstalk_report = @campaign.order.get_report(start_date = @campaign.start_time.to_date, end_date = @date)
    return false unless @bidstalk_report
    @bidstalk_report = @bidstalk_report.first

    CampaignDspDriver.new(@date).create_campaign_dsp_infos(@campaign)
    @campaign_dsp_info = @campaign.campaign_dsp_infos.find_by(date: @date)

    return false unless (@campaign_dsp_info && (@campaign_dsp_info.clicks.to_i > 0 || @campaign_dsp_info.impressions.to_i > 0)) ||
        @daily_trackings.exists?

    @campaign_dsp_info ||= @campaign.campaign_dsp_infos.create(date: @date,
                                                               daily_tracking_views: 0,
                                                               daily_tracking_clicks: 0,
                                                               spend: 0, ecpc: 0, ecpm: 0)

    unless @daily_trackings.exists?
      DailyTrackingRecord.create!(date: @date, campaign_id: @campaign.id,
                                  order_id: @campaign.order.id,
                                  dsp_id: Platform.bidstalk.id,
                                  banner_id: @campaign.banners.first.id,
                                  views: 0, clicks: 0)

      LocationTrackingRecord.create!(date: @date, campaign_id: @campaign.id,
                                     campaign_location_id: @campaign.campaign_locations.first.id,
                                     banner_id: @campaign.banners.first.id,
                                     views: 0, clicks: 0)

      TrackingModels::OsTracking.create!(date: @date, campaign_id: @campaign.id,
                                         operating_system_id: OperatingSystem.other.id,
                                         banner_id: @campaign.banners.first.id,
                                         views: 0, clicks: 0)

      TrackingModels::CarrierTracking.find_or_create_by!(date: @date, campaign_id: @campaign.id,
                                                         banner_id: @campaign.banners.first.id,
                                                         name: 'OTHERS') { |r| r.views = 0; r.clicks = 0 }

      TrackingModels::AppTracking.find_or_create_by!(date: @date, campaign_id: @campaign.id,
                                                         banner_id: @campaign.banners.first.id,
                                                         name: 'OTHERS') { |r| r.views = 0; r.clicks = 0 }

      TrackingModels::Exchange.find_or_create_by!(date: @date, campaign_id: @campaign.id,
                                                  banner_id: @campaign.banners.first.id,
                                                  name: 'OTHERS') { |r| r.views = 0; r.clicks = 0 }

    end

    true
  end
end