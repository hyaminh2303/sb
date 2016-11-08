module Reports::Campaigns::LocationReport
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
    query LocationTrackingRecord, "campaign_location_id, (SELECT name FROM #{CampaignLocation.table_name} WHERE id = #{LocationTrackingRecord.table_name}.campaign_location_id) as name, SUM(views) as views, SUM(clicks) as clicks", 'name', nil
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
