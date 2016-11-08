module Reports::Campaigns::DateReport
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
    query DailyTrackingRecord, 'date, SUM(views) as views, SUM(clicks) as clicks', 'date', nil
  end

  def get_order_column(index)
    case index
      when 0
        'date'
      when 1
        'views'
      when 2
        'clicks'
      when 3
        'ROUND((SUM(clicks)/NULLIF(SUM(views),0)),4)'
      else
        'date'
    end
  end
end
