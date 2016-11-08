module Reports::Campaigns::ExchangeReport
  include Reports::Campaigns::Base

  protected
  def init_report(options)
    init_campaign(options)
    @options = options
    query TrackingModels::Exchange, 'name, SUM(views) as views, SUM(clicks) as clicks', 'name', nil
  end

  def get_order_column(index)
    case index
      when 1
        'name'
      when 2
        'views'
      when 3
        'clicks'
      when 4
        'ROUND((SUM(clicks)/NULLIF(SUM(views),0)),4)'
      else
        'name'
    end
  end
end