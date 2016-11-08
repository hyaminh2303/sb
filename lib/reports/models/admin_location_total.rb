class Reports::Models::AdminLocationTotal < Reports::Models::AdminLocation
  include Reports::Helpers::CampaignReportHelper

  def initialize(details, campaign)
    @views = get_total_views(details)
    @clicks = get_total_clicks(details)

    @ctr = get_ctr_by_total(details)
    @spend = get_total_spend(details, campaign)
  end
end
