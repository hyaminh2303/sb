class Reports::Models::AgencyDevice
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :group_ads_name

  def initialize(detail, campaign)
    init_detail(detail)
    @group_ads_name = detail.name
    @spend = get_spend(detail, campaign)
  end

  def hash
    _hash = hash_detail

    unless @group_ads_name.nil?
      _hash[:group_ads_name] = @group_ads_name
    end
    _hash
  end
end
