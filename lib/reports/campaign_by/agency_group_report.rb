class Reports::CampaignBy::AgencyGroupReport
  include Reports::Campaigns::GroupReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      instance = Reports::Models::AgencyGroup.new detail, @campaign
      instance.data = get_daily_details(detail, options)
      instance
    end unless options[:skip_details]

    @total = Reports::Models::AgencyCampaignTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_group'
  end

  private
  def get_daily_details(model, options)
    condition = where_condition options
    condition[:group_id] = model.group_id

    DailyTracking.select('date, SUM(views) as views, SUM(clicks) as clicks').where(condition).group('date').map do |d|
      Reports::Models::AgencyGroup.new d, @campaign, :sub
    end
  end
end
