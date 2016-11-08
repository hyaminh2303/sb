class Reports::Models::AdminOs
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :name

  def initialize(detail, campaign)
    init_detail(detail, campaign)

    @name = detail.name
  end

  def hash
    _hash = hash_detail

    unless @name.nil?
      _hash[:name] = @name
    end

    _hash
  end
end
