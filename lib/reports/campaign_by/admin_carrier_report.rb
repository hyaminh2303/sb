class Reports::CampaignBy::AdminCarrierReport
  include Reports::Campaigns::CarrierReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AdminCarrier.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AdminCarrierTotal.new @campaign_details, @campaign
  end

  def template_name
    'admin_by_carrier'
  end
end
