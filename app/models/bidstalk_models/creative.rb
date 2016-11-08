module BidstalkModels
  class Creative

    # region Methods

    def initialize(banner, campaign = nil)
      @banner = banner
      @campaign = campaign || banner.campaign
    end

    #
    # get creative id on bidstalk
    #
    def platform_id
      @banner.dsp_creative_id
    end

    #
    # check if creative is created on bidstalk
    #
    def created?
      @banner.dsp_creative_id.present?
    end

    #
    # to bidstalk creative
    #
    def to_platform_creative!
      return nil if @banner.new_record?
      {
          campaign_id: @campaign.order.dsp_campaign_id,
          creative_title: URI.encode(@banner.name.gsub(/\W+/, '_')),
          creative_type: @campaign.banner_type.dsp_info(Platform.bidstalk.id).banner_type_code,
          creative_img_url: URI.encode(@banner.image.url),
          creative_target_url: URI.encode(TrackingAPI.click_url(@banner.key, @banner.landing_url)),
          creative_img_mime: URI.encode('image/*'),
          pixel_url: URI.encode(TrackingAPI.impression_url(@banner.key))
      }
    end

    #
    # create creative on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] creative on bidstalk
    #
    def create
      return nil if created?
      request :create_creative_on_bidstalk do
        client = Bidstalk::Creative::Client.new
        client.create to_platform_creative!
      end
    end

    #
    # get creative on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] creative on bidstalk
    #
    def get
      return nil unless created?
      request :get_creative_on_bidstalk do
        client = Bidstalk::Creative::Client.new
        client.get_by_id platform_id
      end
    end

    #
    # delete creative on bidstalk
    # @see http://advertiser.bidstalk.com/apidocs.php for more information
    # @return [Hash] creative on bidstalk
    #
    def delete
      return nil unless created?
      request :delete_creative_on_bidstalk do
        client = Bidstalk::Creative::Client.new
        client.delete platform_id
      end
    end


    # endregion

    # region Private Methods

    private

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