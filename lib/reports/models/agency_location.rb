class Reports::Models::AgencyLocation
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :location_name

  def initialize(detail, campaign)
    init_detail(detail)

    @location_name = detail.name
    @spend = get_spend(detail, campaign)
  end

  def hash
    _hash = hash_detail

    unless @location_name.nil?
      _hash[:location_name] = @location_name
    end

    _hash
  end
end
