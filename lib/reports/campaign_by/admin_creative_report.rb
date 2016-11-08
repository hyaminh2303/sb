class Reports::CampaignBy::AdminCreativeReport
  include Reports::Campaigns::CreativeReport

  def initialize(options)
    init_report(options)
    order_by_name = order_index(options) == 1

    @data = @campaign_details.map do |detail|
      Reports::Models::AdminCreative.new detail, @campaign
    end unless options[:skip_details]

    if order_by_name
      @data.sort! { |x, y| x.creative_name <=> y.creative_name }
      @data.reverse! if order_sort(@options) == 'ASC'
    end

    @total = Reports::Models::AdminCreativeTotal.new @campaign_details, @campaign
  end

  def template_name
    'admin_by_creative'
  end
end
