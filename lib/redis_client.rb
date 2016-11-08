class RedisClient

  attr_reader :redis

  def initialize
    @redis = Redis.new(host: APP_CONFIG['redis']['tracking']['host'], port: APP_CONFIG['redis']['tracking']['port'])
  end

  def set_tracking_impression(creative_key, campaign_location_key, date, view)
    @redis.set(impression_key(creative_key, campaign_location_key, date), view)
  end

  def set_tracking_click(creative_key, campaign_location_key, date, click)
    @redis.set(click_key(creative_key, campaign_location_key, date), click)
  end

  def set_banner_locations(banner_key, locations)
    @redis.sadd(banner_location_key(banner_key), "#{locations.id},#{locations.latitude},#{locations.longitude},#{locations.radius}")
  end

  private

  def impression_key(creative_key, campaign_location_key, date)
    "#{creative_key}:#{campaign_location_key}:#{date}:m"
  end

  def click_key(creative_key, campaign_location_key, date)
    "#{creative_key}:#{campaign_location_key}:#{date}:c"
  end

  def banner_location_key(banner_key)
    "#{banner_key}:locations"
  end
end