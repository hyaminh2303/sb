class Reports::Models::TrackingData

  def initialize(campaign_details, request_options, detail_class, detail_total_class, campaign = nil)
    @campaign_details = campaign_details
    @request_options = request_options
    @detail_class = detail_class
    @detail_total_class = detail_total_class

    @campaign = campaign
  end

  def map_data(&block)
    @data = @campaign_details.map do |detail|
      instance = @detail_class.new detail: detail, campaign: @campaign

      if block_given?
        instance.data = block.call detail, @request_options
      end

      instance
    end unless @request_options[:skip_details]
  end

  def map_total
    @total = @detail_total_class.new campaign_details: @campaign_details, campaign: @campaign
  end
end
