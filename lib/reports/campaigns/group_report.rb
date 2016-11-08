module Reports::Campaigns::GroupReport
  include Reports::Campaigns::Base

  protected
  # ==== Parameters
  # * +options+ - Options for query report:
  #   :campaign_id =>
  #   :group_id =>
  #   :start => Index of start record, for by datatable
  #   :length => Length per page by datatable
  #   :order[0]{ :column, :dir} => Order column index & dir (asc, desc)
  def init_report(options)
    init_campaign(options)
    @options = options
    query DailyTracking, 'group_id, (SELECT name FROM campaign_ads_groups WHERE id = group_id) as group_name, SUM(views) as views, SUM(clicks) as clicks, SUM(spend) as spend', 'group_id'
  end

  def get_order_column(index)
    case index
      when 0
        'group_name'
      when 1
        'views'
      when 2
        'clicks'
      when 3
        'ROUND((SUM(clicks)/NULLIF(SUM(views),0)),4)'
      when 4
        'spend'
      else
        'group_id'
    end
  end
end
