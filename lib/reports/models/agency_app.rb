class Reports::Models::AgencyApp
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :app_name

  def initialize(detail, campaign)
    init_detail(detail, campaign)

    @app_name = detail.name
    @spend = get_spend(detail, campaign)
  end

  def hash
    _hash = hash_detail

    unless @carrier_name.nil?
      _hash[:app_name] = @app_name
    end
    _hash
  end
end
