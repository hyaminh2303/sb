class Reports::CampaignBy::AgencyAppReport
  include Reports::Campaigns::AppReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AgencyApp.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AgencyAppTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_app'
  end
end
