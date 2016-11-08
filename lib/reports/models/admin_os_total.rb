class Reports::Models::AdminOsTotal < Reports::Models::AdminOs
  include Reports::Helpers::CampaignReportHelper

  def initialize(details, campaign)
    @views = get_total_views(details)
    @clicks = get_total_clicks(details)
    @spend = get_total_spend(details, campaign)

    @ctr = get_ctr_by_total(details)
  end
end
