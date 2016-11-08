class Reports::Models::AgencyCreative
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :creative_name

  def initialize(detail, campaign)
    init_detail(detail, campaign)
    @creative_name = detail.banner.name
    @spend = get_spend(detail, campaign)
  end

  def hash
    _hash = hash_detail

    unless @creative_name.nil?
      _hash[:creative_name] = @creative_name
    end
    _hash
  end
end
