class Reports::CampaignBy::AgencyLocationReport
  include Reports::Campaigns::LocationReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AgencyLocation.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AgencyLocationTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_location'
  end
end
