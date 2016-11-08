module BidstalkMapping
  class Client
    class << self

      def launch_campaign(model_campaign)
        @model_campaign = model_campaign

        if @model_campaign.order.blank?
          campaign = create_campaign

          @model_campaign.order = Order.new({
                                                campaign_id: @model_campaign.id,
                                                dsp_id: Platform.bidstalk.id,
                                                dsp_campaign_id: campaign[:campaign_id]
                                            }) if campaign.present?
        else
          campaign = {campaign_id: @model_campaign.order.dsp_campaign_id}
        end

        if campaign.present?

          @redis = RedisClient.new

          @model_campaign.banners.each do |banner|
            creative = create_creative banner, campaign[:campaign_id]
            banner.dsp_creative_id = creative[:creative_id] if creative.present?

            @model_campaign.campaign_locations.each do |campaign_location|
              @redis.set_banner_locations(banner.key, campaign_location)
            end
          end

          @model_campaign.is_draft = false
          @model_campaign.save if @model_campaign.errors.none?
        end
      end

      def pause_campaign(model_campaign, campaign_id)
        @model_campaign = model_campaign
        request :pause_campaign do
          Bidstalk::Campaign::Client.new.pause campaign_id
        end
      end

      def resume_campaign(model_campaign, campaign_id)
        @model_campaign = model_campaign
        request :resume_campaign do
          Bidstalk::Campaign::Client.new.resume campaign_id
        end
      end

      private

      def creative_info(banner, campaign_id)
        {
            campaign_id: campaign_id,
            creative_title: URI.encode(banner.name.gsub(/\W+/,'_')),
            creative_type: @model_campaign.banner_type.dsp_info(Platform.bidstalk.id).banner_type_code,
            creative_img_url: URI.encode(banner.image.url),
            creative_target_url: URI.encode(TrackingAPI.click_url(banner.key, banner.landing_url)),
            creative_img_mime: URI.encode('image/*'),
            pixel_url: URI.encode(TrackingAPI.impression_url(banner.key))
        }
      end

      ## campaign_info
      # {
      #     title: "Test Campaign api",
      #     date_range: '2015-03-29 08:05:28|2015-04-05 08:05:2', # YYYY-MM-DD HH:MM:SS|YYYY-MM-DD HH:MM:SS
      #     max_bid: 0.2,
      #     ad_domain: 'http://yoose.com',
      #     daily_budget: 25,
      #     total_budget: 26,
      #     timezone: 11,
      #     campaign_type: 1,
      #     creative_type: 1,
      #     target_countries: 210,
      #     target_states: 'all',
      #     target_carriers: 'all',
      #     target_connection_type: 'all',
      #     target_manufacturers: 'all',
      #     target_os: '11,12',
      #     target_os_version: 'all',
      #     target_devices: 'all',
      #     target_categories: 'all',
      #     target_ages: '11,12',
      #     target_gender: '11',
      #     target_interests: 'all',
      #     target_exchanges: '11,12,13,14,15,20,21,23,24,27,28,29',
      #     conversion_type: 'NONE',
      #     conversion_target_cpi: 'none'
      #     geo_mapping: '34.53344598,-63.9874650,5|21.876520,-8.987652,1' #Format should be latitude,longitude,radius. Multiple geolocation targets seperated by "|"
      # }
      ##
      def campaign_info
        m = @model_campaign
        {
            title: m.name,
            date_range: date_range,
            max_bid: 0.01,
            ad_domain: m.ad_domain,
            daily_budget: 25,
            total_budget: 200,
            timezone: m.timezone.dsp_info(Platform.bidstalk.id).timezone_code,
            campaign_type: m.campaign_type.dsp_info(Platform.bidstalk.id).campaign_type_code,
            creative_type: m.banner_type.dsp_info(Platform.bidstalk.id).banner_type_code,
            target_countries: m.country.dsp_info(Platform.bidstalk.id).country_code,
            target_states: 'all',
            target_carriers: 'all',
            target_connection_type: 'all',
            target_manufacturers: 'all',
            target_os: target(:operating_system),
            target_os_version: 'all',
            target_devices: 'all',
            target_categories: m.category.dsp_info(Platform.bidstalk.id).category_code,
            target_ages: target(:age_range),
            target_gender: target(:gender),
            target_interests: target(:interest),
            target_exchanges: '11,12,13,14,15,20,21,23,24,27,28,29',
            conversion_type: 'NONE',
            conversion_target_cpi: 'none',
            geo_mapping: geo_mapping
        }

      end

      def date_range
        timezone = ActiveSupport::TimeZone.new(@model_campaign.timezone.zone)
        if @model_campaign.start_time.to_date == Date.today
          start_date = 1.hour.since(Time.now.in_time_zone(timezone)).at_beginning_of_minute.strftime(Date::DATE_FORMATS[:date_time])
        else
          start_date = 1.second.since(@model_campaign.start_time).strftime(Date::DATE_FORMATS[:date_time])
        end
        end_date = @model_campaign.end_time.at_end_of_day.strftime(Date::DATE_FORMATS[:date_time])
        "#{start_date}|#{end_date}"
      end

      def geo_mapping
        @model_campaign.campaign_locations.map { |l| "#{l.latitude},#{l.longitude},#{l.radius}" }.join('|')
      end

      def target(model)
        model_mapping = "#{model.to_s.camelize}DspMapping".constantize
        target_value=@model_campaign.send(model.to_s.pluralize).joins("INNER JOIN #{model_mapping.table_name} ON #{model_mapping.table_name}.#{model}_id=sb_campaigns_#{model.to_s.pluralize}.#{model}_id").pluck("#{model_mapping.table_name}.#{model}_code").join(',')
        target_value.empty? ? 'all' : target_value
      end

      def create_creative(banner, campaign_id)
        request :create_creative do
          client = Bidstalk::Creative::Client.new
          client.create(creative_info banner, campaign_id)
        end
      end

      def create_campaign
        request :create_campaign do
          client = Bidstalk::Campaign::Client.new
          client.create(campaign_info)
        end
      end

      def request(name)
        begin
          yield
        rescue Bidstalk::InvalidArgumentError => e
          Rails.logger.error "[#{Time.new}] Bidstalk: #{name.to_s.humanize.capitalize} failed: #{e.message}"
          @model_campaign.errors.add(:base, "Bidstalk: #{name.to_s.humanize.capitalize} is failed: #{e.message}")
          nil
        rescue Bidstalk::Error => e
          Rails.logger.error "[#{Time.new}] Bidstalk: #{name.to_s.humanize.capitalize} failed: #{e.message}"
          @model_campaign.errors.add(:base, "Bidstalk: #{name.to_s.humanize.capitalize} is failed: #{e.message}")
          nil
        end
      end
    end
  end
end