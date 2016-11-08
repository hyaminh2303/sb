class Reports::CampaignBy::AgencyOsReport
  include Reports::Campaigns::OsReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AgencyOs.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AgencyOsTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_os'
  end
end
