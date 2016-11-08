require 'workers/worker_helper'

describe :daily_tracking do
  include_context :fake_tracking_data

  context 'with valid tracking data' do
    it 'counts tracking data into mysql' do
      DailyTrackingWorker.new.perform

      new_daily_tracking = DailyTrackingRecord.find_by(@daily_tracking_info)
      expect(new_daily_tracking.attributes).to include(
                                                   'views'  => @daily_tracking.views + @view,
                                                   'clicks' => @daily_tracking.clicks + @click
                                               )

      new_location_tracking = LocationTrackingRecord.find_by(@location_tracking_info)
      expect(new_location_tracking.attributes).to include(
                                                      'views'  => @location_tracking.views + @view,
                                                      'clicks' => @location_tracking.clicks + @click
                                                  )
    end
  end
end