module TrackingAPI
  class << self
    def click_url(creative_id, landing_url)
      "#{endpoint}/clk?#{basic_params creative_id}&redirect=#{CGI::escape(landing_url)}"
    end

    def impression_url(creative_id)
      "#{endpoint}/imp?#{basic_params creative_id}"
    end

    private

    def endpoint
      ENV['tracking_api_endpoint']
    end

    def basic_params(creative_id)
      "creative_id=#{creative_id}&device_id={DEVICE_ID}&lat={GPS_LAT}&lng={GPS_LON}&device_os_name={DEVICE_OS_NAME}&device_platform_id={DEVICE_PLATFORM_ID}&model_name={MODEL_NAME}&conversion_id={CONVERSION_ID}&campaign={CAMPAIGN}&creative={CREATIVE}&app_name={APP_NAME}&exchange_name={EXCHANGE_NAME}&manufacturer_name={MANUFACTURER_NAME}&carrier_name={CARRIER_NAME}&country_name={COUNTRY_NAME}&state_name={STATE_NAME}&timestamp={TIMESTAMP}&user_ip={USER_IP}&country_code={COUNTRY_CODE}&app_id={APP_ID}&publisher_id={PUBLISHER_ID}"
    end
  end
end

