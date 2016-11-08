module Reports::Campaigns::DeviceReport
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

    # specify whether ad group column is visible. If there is no campaign_ads_group_id then definitely no need to show such column
    # query TrackingModels::DevicePlatformTracking, 'COUNT(DISTINCT name) as name, date, SUM(views) as views, SUM(clicks) as clicks', 'date', nil
    query DailyTrackingRecord, 'date, IFNULL(SUM(num_of_devices), 0) AS name, SUM(views) AS views, SUM(clicks) AS clicks', 'date', nil
  end

  def get_order_column(index)
    case index
      when 1
        'date'
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