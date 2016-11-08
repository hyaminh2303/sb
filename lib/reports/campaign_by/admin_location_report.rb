class Reports::CampaignBy::AdminLocationReport
  include Reports::Campaigns::LocationReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AdminLocation.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AdminLocationTotal.new @campaign_details, @campaign
  end

  def template_name
    'admin_by_location'
  end
end
