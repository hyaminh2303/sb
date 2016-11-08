class Reports::Models::AdminLocation
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :location_name

  def initialize(detail, campaign)
    init_detail(detail, campaign)

    @location_name = detail.name

  end

  def hash
    _hash = hash_detail

    unless @location_name.nil?
      _hash[:location_name] = @location_name
    end

    _hash
  end
end
