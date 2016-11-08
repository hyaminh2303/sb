class Reports::Models::AgencyCampaign
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_accessor :data

  def initialize(detail, campaign)
    init_detail(detail)

    # @spend = get_spend(detail, campaign)
  end

  def hash
    _hash = hash_detail

    unless data.nil?
      _hash[:data] = data.map do |d|
        d.hash
      end
    end

    _hash
  end
end
