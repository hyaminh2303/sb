class Reports::CampaignBy::AdminAppReport
  include Reports::Campaigns::AppReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AdminApp.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AdminAppTotal.new @campaign_details, @campaign
  end

  def template_name
    'admin_by_app'
  end
end
