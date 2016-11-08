class Reports::CampaignBy::AdminOsReport
  include Reports::Campaigns::OsReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AdminOs.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AdminOsTotal.new @campaign_details, @campaign
  end

  def template_name
    'admin_by_os'
  end
end
