class Reports::Models::AdminApp
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :app_name

  def initialize(detail, campaign)
    init_detail(detail, campaign)

    @app_name = detail.name
  end

  def hash
    _hash = hash_detail

    unless @app_name.nil?
      _hash[:app_name] = @app_name
    end
    _hash
  end
end
