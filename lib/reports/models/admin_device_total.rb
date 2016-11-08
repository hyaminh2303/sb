class Reports::Models::AdminDeviceTotal < Reports::Models::AdminDevice
  include Reports::Helpers::CampaignReportHelper

  def initialize(details, campaign)
    @views = get_total_views(details)
    @clicks = get_total_clicks(details)
    @ctr = get_ctr_by_total(details)
    @spend = get_total_spend(details, campaign)
    @num_of_unique_device = get_total_number_of_device_ids(details)
  end
end
