class Extractor
  TRACKING_TYPES = {
    daily_tracking: DailyTrackingRecord,
    campaign_location_id: LocationTrackingRecord,
    carrier_name: TrackingModels::CarrierTracking,
    device_os_name: TrackingModels::OsTracking,
    exchange_name: TrackingModels::Exchange,
    app_name: TrackingModels::AppTracking
  }

  def initialize(date, campaign=nil)
    @date = date
    @campaign = campaign
    if campaign.present?
      @creative_ids = Banner.with_deleted.where(campaign_id: campaign.id).pluck(:id) if campaign.present?
      # TODO: need to be improved
      @creative_ids += @creative_ids.map{|t| t.to_s}
    end

  end

  def run
    beginning_of_day = @date.beginning_of_day
    end_of_day = @date.end_of_day

    TRACKING_TYPES.each do |tracking_type, model_class|
      group_by = {}.tap do |group|
        group[:creative_id] = '$creative_id'
        group[tracking_type] = "$#{tracking_type.to_s}" unless tracking_type == :daily_tracking
      end

      condition = {timestamp: {:$gte => beginning_of_day, :$lte => end_of_day}}
      condition.merge!(creative_id: {:$in => @creative_ids}) if @creative_ids.present?

      pipeline = [
        {:$match => condition},
        {:$group => {_id: group_by, views: {:$sum => '$views'}, clicks: {:$sum => '$clicks'}}}
      ]

      if tracking_type == :daily_tracking
        pipeline[1][:$group][:devices] = {:$push => '$devices'}
        pipeline << {:$unwind => '$devices'}
        pipeline << {:$unwind => '$devices'}
        pipeline << {:$group => {_id: '$_id', views: {:$first => '$views'}, clicks: {:$first => '$clicks'}, devices: {:$addToSet => '$devices'}}}
      end

      # delete date's data
      # condition = {date: @date.to_date}
      # condition[:campaign_id] = @campaign.id if @campaign.present?
      # model_class.where(condition).delete_all

      aggregation = MongoDb::DailyStat.collection.aggregate(pipeline)
      aggregation.each do |doc|
        data = prepare_data(tracking_type, doc)
        next unless data
        tracking_record = model_class.find_or_create_by!(data)
        # tracking_record.clicks ||= 0
        # tracking_record.views ||= 0
        tracking_record.clicks = doc['clicks']
        tracking_record.views = doc['views']

        if tracking_type == :daily_tracking
          devices = doc['devices']
          tracking_record.devices = devices
          tracking_record.num_of_devices = devices.size
        end
        tracking_record.save!
      end
    end
  end

  private

  def prepare_data(tracking_type, data)
    creative = Banner.with_deleted.find_by(id: data['_id']['creative_id'])
    return nil unless creative

    info = {campaign_id: creative.campaign_id,
            banner_id: creative.id,
            date: @date.to_date}

    case tracking_type
      when :daily_tracking
        info.merge!(
          dsp_id: creative.campaign.order.dsp_id,
          order_id: creative.campaign.order.id)
      when :exchange_name, :carrier_name, :app_name
        info.merge!(name: data['_id'][tracking_type.to_s] || 'Others')
      when :device_os_name
        os = OperatingSystem.find_by(name: data['_id'][tracking_type.to_s]) || OperatingSystem.other
        info[:operating_system_id] = os.id
      else
        info[tracking_type] = data['_id'][tracking_type.to_s]
    end
    info
  end
end

