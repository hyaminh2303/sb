module Reports::Campaigns::CreativeReport
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
    query DailyTrackingRecord, 'banner_id, SUM(views) as impressions, SUM(clicks) as clicks', 'banner_id', nil
  end

  def get_order_column(index)
    case index
      when 1
        'banner_id'
      when 2
        'impressions'
      when 3
        'clicks'
      when 4
        'ROUND((SUM(clicks)/NULLIF(SUM(views),0)),4)'
      else
        'banner_id'
    end
  end
end