class Reports::CampaignBy::AgencyCreativeReport
  include Reports::Campaigns::CreativeReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AgencyCreative.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AgencyCreativeTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_creative'
  end
end
