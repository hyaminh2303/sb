module MongoDb
  class DailyStat
    include Mongoid::Document
    store_in collection: :daily_stats

    field :timestamp, type: Time
    field :creative_id, type: String
    field :campaign_location_id, type: Integer
    field :device_os_name, type: String
    field :device_platform_name, type: String
    field :exchange_name, type: String
    field :carrier_name, type: String
    field :state_name, type: String
    field :devices, type: Array
    field :views, type: Integer
    field :clicks, type: Integer
  end
end