class Reports::Models::AdminDevice
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_reader :group_ads_name
  attr_reader :counted
  attr_reader :num_of_unique_device

  def initialize(detail, campaign)
    init_detail(detail, campaign)
    @counted        = detail.name
    @group_ads_name = detail.date
  end

  def hash
    _hash = hash_detail

    unless @group_ads_name.nil?
      _hash[:group_ads_name] = @group_ads_name
      _hash[:counted]        = @counted
    else
      _hash[:group_ads_name] = ''
      _hash[:counted]        = 0
    end
    _hash
  end
end
