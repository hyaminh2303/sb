class Reports::CampaignBy::AdminExchangeReport
  include Reports::Campaigns::ExchangeReport

  def initialize(options)
    init_report(options)
    @data = @campaign_details.map do |detail|
      Reports::Models::AdminExchange.new detail, @campaign
    end unless options[:skip_details]
    @total = Reports::Models::AdminExchangeTotal.new @campaign_details, @campaign
  end
end