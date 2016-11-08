class Reports::CampaignBy::AdminDailyReport
  include Reports::Campaigns::DateReport

  def initialize(options)
    init_report(options)
    @data = @campaign_details.map do |detail|
      instance = Reports::Models::AdminCampaign.new detail, @campaign, options[:user]
      # instance.data = get_daily_details(detail, options)
      instance
    end unless options[:skip_details]

    @total = Reports::Models::AdminCampaignTotal.new @campaign_details, @campaign, options[:user]

  end

  def template_name
    'admin_by_date'
  end

  # private
  # def get_daily_details(model, options)
  #   condition = where_condition options
  #   condition[:date] = model.date
  #
  #   DailyTracking.select('SUM(views) as views, SUM(clicks) as clicks, SUM(spend) as spend, platform_id').where(condition).group('platform_id').map do |d|
  #     Reports::Models::AdminCampaign.new d, type: :sub
  #   end
  #
  # end
end
