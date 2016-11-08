class Reports::Models::AgencyCarrier
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :carrier_name

  def initialize(detail, campaign)
    init_detail(detail, campaign)

    @carrier_name = detail.name
    @spend = get_spend(detail, campaign)
  end

  def hash
    _hash = hash_detail

    unless @carrier_name.nil?
      _hash[:carrier_name] = @carrier_name
    end
    _hash
  end
end
