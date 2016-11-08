class Reports::CampaignBy::AgencyCarrierReport
  include Reports::Campaigns::CarrierReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AgencyCarrier.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AgencyCarrierTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_carrier'
  end
end
