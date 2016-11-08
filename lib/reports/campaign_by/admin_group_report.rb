class Reports::CampaignBy::AdminGroupReport
  include Reports::Campaigns::GroupReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      instance = Reports::Models::AdminGroup.new detail
      instance.data = get_daily_details(detail, options)
      instance
    end unless options[:skip_details]

    @total = Reports::Models::AdminCampaignTotal.new @campaign_details
  end

  def template_name
    'admin_by_group'
  end

  private
  def get_daily_details(model, options)
    condition = where_condition options
    condition[:group_id] = model.group_id

    DailyTracking.select('date, SUM(views) as views, SUM(clicks) as clicks, SUM(spend) as spend').where(condition).group('date').map do |d|
      Reports::Models::AdminGroup.new d, :sub
    end
  end
end
