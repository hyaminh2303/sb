require 'tempfile'
module BidstalkModels
  class Campaign
    #region Constants
    KM_TO_MILES = 0.621371192
    IMPRESSION_CAP = 20
    MAX_BID = 0.05
    #
    # default bidstalk campaign values
    #
    DEFAULT_CAMPAIGN_VALUES = {
        day_budget: 25
    }

    #
    # @example 2015-03-29 08:05:28
    #
    DATE_FORMAT = Setting['campaign.bidstalk.date_format']

    #endregion

    # region Methods

    def initialize(campaign)
      @campaign = campaign
    end

    #
    # get campaign id on bidstalk
    #
    def platform_id!
      @campaign.order.dsp_campaign_id
    end

    #
    # check if campaign is created on bidstalk
    #
    def created?
      @campaign.order.dsp_campaign_id.present? && @campaign.order.dsp_id == Platform.bidstalk.id
    end

    def create_params
      {
        campaign_type: CampaignType.cpc.name,
        creative_type: 1,
        impression_cap: IMPRESSION_CAP,
        max_bid: MAX_BID,
        total_budget: 1000,
        creatives: new_creatives,
        timezone: 50,
        targeting: {
          countries: [@campaign.country.dsp_info(Platform.bidstalk.id).country_code],
          categories: to_category_ids_string(@campaign.categories),
          genders: to_gender_ids_string(@campaign.genders)
        }
      }
    end

    def edit_params
      hash = {campaign_id: platform_id!}
      hash[:creatives] = {}.tap do |hash|
                            hash[:create] = new_creatives if new_creatives.present?
                            hash[:delete] = deleted_creatives if deleted_creatives.present?
                          end if new_creatives.present? || deleted_creatives.present?
      hash[:targeting] = {
                            oss: to_os_ids_string(@campaign.operating_systems),
                            categories: to_category_ids_string(@campaign.categories),
                            genders: to_gender_ids_string(@campaign.genders)
                          } if @campaign.target_city
      hash
    end

    #
    # to bidstalk campaign
    #
    def to_platform_campaign!(is_create = true, campaign_params = nil)
      return nil if @campaign.new_record?
      bidstalk_campaign =
          {
              title: @campaign.name,
              domain: @campaign.ad_domain,
              targeting: {
                exchanges: 'ALL',
                oss: to_os_ids_string(@campaign.operating_systems),
              }.tap { |hash|
                  hash[:geo_map] = to_geo_mapping_string(@campaign.campaign_locations) if @campaign.campaign_locations.present?
              }
          }

      start_time = [@campaign.start_time, Time.now + 2.hours].max
      bidstalk_campaign[:start_time] = start_time.strftime('%Y-%m-%d %H:%M:%S') if @campaign.start_time >= Date.today
      bidstalk_campaign[:end_time] = @campaign.end_time.strftime('%Y-%m-%d %H:%M:%S')

      bidstalk_campaign[:devices_whitelist] = @campaign.whitelistings.devices.whitelist.url if @campaign.target_city && @campaign.whitelistings.present? && @campaign.target_campaign_ids.present?

      if created?
        bidstalk_campaign.deep_merge! edit_params
      else
        bidstalk_campaign.deep_merge! create_params
      end

      campaign_params = if campaign_params.nil?
                          DEFAULT_CAMPAIGN_VALUES.merge bidstalk_campaign
                        else
                          campaign_params.merge bidstalk_campaign
                        end
    end

    #
    # create campaign on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] campaign on bidstalk
    #
    def create
      return nil if created?
      request :create_campaign_on_bidstalk do
        client = Bidstalk::Campaign::Client.new
        client.create to_platform_campaign!
      end
    end

    #
    # create creative on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    #
    def create_creative
      @campaign.banners.each do |banner|
        creative = BidstalkModels::Creative.new banner, @campaign
        creative_info = creative.create

        if creative_info
          banner.dsp_creative_id = creative_info[:creative_id]
          banner.save
        end
      end
    end

    #
    # get campaign on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] campaign on bidstalk
    #
    def get
      return nil unless created?
      request :get_campaign_on_bidstalk do
        client = Bidstalk::Campaign::Client.new
        client.get_by_id platform_id!
      end
    end

    #
    # pause campaign on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] {:campaign_id, :campaign_title, :campaign_status}
    #
    def pause
      return nil unless created?
      request :pause_campaign_on_bidstalk do
        client = Bidstalk::Campaign::Client.new
        client.pause platform_id!
      end
    end

    #
    # resume campaign on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] {:campaign_id, :campaign_title, :campaign_status}
    #
    def resume
      return nil unless created?
      request :resume_campaign_on_bidstalk do
        client = Bidstalk::Campaign::Client.new
        client.resume platform_id!
      end
    end

    #
    # update campaign on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] campaign on bidstalk
    #
    def edit(campaign_params = nil)
      return nil unless created?
      request :update_campaign_on_bidstalk do
        client = Bidstalk::Campaign::Client.new
        client.update to_platform_campaign!(false, campaign_params)
      end
    end

    #
    # update creative on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    #
    def save_creative
      @campaign.banners.each do |banner|
        creative = BidstalkModels::Creative.new banner, @campaign
        unless creative.created?
          creative_info = creative.create
          banner.dsp_creative_id = creative_info[:creative_id]
          banner.save
        end
      end
    end

    # delete campaign on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    #
    def delete_campaign
      return nil unless created?
      request :delete_campaign_on_bidstalk do
        client = Bidstalk::Campaign::Client.new
        client.delete platform_id!
      end
    end

    #
    # delete creative on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    #
    def delete_creative
      banners = Banner.only_deleted.where(campaign_id: @campaign.id)
      banners.each do |banner|
        task = BidstalkTask::DeleteBanner.find_or_create_by!(campaign_id: @campaign.id, banner_id: banner.id)
        task.run
      end
    end

    # endregion

    # region Private Methods

    def get_report(start_date, end_date)
      return nil unless created?
      request :get_report_campaign_on_bidstalk do
        client = Bidstalk::Report::Client.new
        client.lists( { campaigns: [platform_id!] }, start_date, end_date )
      end
    end

    private
    #
    # Convert start time & end time to time in timezone
    # @return [string] '2015-03-29 08:05:28|2015-04-05 08:05:2'
    #
    def to_date_range_string(start_time, end_time, timezone)
      now = DateTime.now.in_time_zone(timezone.zone)
      s = now.to_date == start_time.to_date ? 1.hours.since(now).at_beginning_of_minute : start_time.beginning_of_day.advance(:seconds => 1)
      e = end_time.at_end_of_day
      "#{s.strftime(DATE_FORMAT)}|#{e.strftime(DATE_FORMAT)}"
    end

    def to_os_ids_string(arr)
      arr.length > 0 ? arr.map { |x| x.dsp_info(Platform.bidstalk.id).operating_system_dsp_id } : 'all'
    end

    def to_category_ids_string(arr)
      return 'all' if !@campaign.target_city
      arr.length > 0 ? arr.map { |x| CategoryDspMapping.where(dsp_id: Platform.bidstalk.id, category_id: [x.categories.ids, x.id]).pluck(:category_dsp_id) }.flatten : 'all'
    end

    def to_gender_ids_string(arr)
      return 'all' if !@campaign.target_city
      arr.length > 0 ? arr.map { |x| x.dsp_info(Platform.bidstalk.id).gender_code } : 'all'
    end

    def get_all_exchanges
      AdExchangeDspMapping.where(dsp_id: Platform.bidstalk.id).pluck(:ad_exchange_dsp_id).map(&:inspect)
    end

    #
    # convert locations to geo mapping string
    # @return [string] Array<locations> -> 'lat,lng,radius|lat,lng,radius'
    #
    def to_geo_mapping_string(locations)
      locations.map { |x| "#{x.latitude},#{x.longitude},#{ (x.radius/1000) * KM_TO_MILES }" }
    end

    def new_creatives
      banners = @campaign.banners.where(dsp_creative_id: nil)
      banners.map { |b| {name: "#{b.id}_#{b.name}", click_url: TrackingAPI.click_url(b.key, b.landing_url), image_url: b.image.url, pixel_url: TrackingAPI.impression_url(b.key)} }
    end

    def deleted_creatives
      banners = Banner.only_deleted.where(campaign_id: @campaign.id).map { |b| b.dsp_creative_id }.compact
    end

    #
    # send request to bidstalk api (write log & add to errors if failed)
    #
    def request(name)
      begin
        yield
      rescue Bidstalk::Error => e
        Rails.logger.error "[#{DateTime.now}] #{name.to_s.humanize.capitalize} failed: #{e.message}"
        @campaign.errors.add(:base, "#{name.to_s.humanize.capitalize} failed: #{e.message}")
        nil
      end
    end

    # endregion
  end
end