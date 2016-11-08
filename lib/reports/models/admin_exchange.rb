class Reports::Models::AdminExchange
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  def initialize(detail, campaign)
    init_detail(detail, campaign)

    @exchange_name = detail.name
  end

  def hash
    _hash = hash_detail

    unless @exchange_name.nil?
      _hash[:exchange_name] = @exchange_name
    end
    _hash
  end
end
