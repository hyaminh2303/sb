class Reports::Models::AgencyDeviceTotal < Reports::Models::AgencyDevice
  include Reports::Helpers::CampaignReportHelper

  def initialize(details, campaign)
    @views = get_total_views(details)
    @clicks = get_total_clicks(details)
    @number_of_device_ids = get_total_number_of_device_ids(details)
    @frequency_cap = get_total_frequency_cap(details)
    @ctr = get_ctr_by_total(details)
    @spend = get_total_spend(details, campaign)
  end
end
