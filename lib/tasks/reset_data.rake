namespace :self_booking do
  desc "Reset data"
  task reset_data: :environment do
    Campaign.destroy_all
    DailyTrackingRecord.destroy_all
    Order.destroy_all
    CampaignLocation.destroy_all
    Banner.destroy_all
    DeviceOsTracking.destroy_all
    ApplicationTracking.destroy_all
    CreativeTracking.destroy_all
    TrackingModels::CarrierTracking.destroy_all
    TrackingModels::DevicePlatformTracking.destroy_all
    TrackingModels::Exchange.destroy_all
  end
end
