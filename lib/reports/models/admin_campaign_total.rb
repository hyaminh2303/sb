class Reports::Models::AdminCampaignTotal < Reports::Models::AdminCampaign
  include Reports::Helpers::CampaignReportHelper

  def initialize(details, campaign, user = nil)
    @views = get_total_views(details)
    @clicks = get_total_clicks(details)

    @ctr = get_ctr_by_total(details)

    @spend = user && user.has_role?(:admin) ? get_dsp_total_spend(details, campaign) : get_total_spend(details, campaign)

    @ecpm =  usd (@spend.to_f / get_total_views(details).to_f) * 1000.0 rescue 0
    @ecpc = usd @spend.to_f / get_total_clicks(details).to_f rescue 0
  end
end
