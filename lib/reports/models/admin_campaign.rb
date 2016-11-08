class Reports::Models::AdminCampaign
  include Reports::Models::TrackingRecord
  include Reports::Helpers::CampaignReportHelper

  attr_accessor :data
  attr_reader :platform

  def initialize(detail, campaign, options = {}, user)
    init_detail(detail)
    if user.has_role? :admin
      @spend = get_dsp_spend(detail, campaign)
    else
      @spend = get_spend(detail, campaign)
    end
    @ecpm = get_ecpm(detail, campaign)
    @ecpc = get_ecpc(detail, campaign)
    type(detail, options)
  end

  def ecpm
    @ecpm.nil? ? nil : @ecpm.amount
  end

  def ecpm_formatted
    @ecpm.nil? ? I18n.t('campaigns.not_available') : @ecpm.format
  end

  def ecpc
    @ecpc.nil? ? nil : @ecpc.amount
  end

  def ecpc_formatted
    @ecpc.nil? ? I18n.t('campaigns.not_available') : @ecpc.format
  end

  def hash
    _hash = hash_detail.merge({
                      ecpm: ecpm_formatted,
                      ecpc: ecpc_formatted
                  })

    unless platform.nil?
      _hash[:platform] = platform
    end

    unless data.nil?
      _hash[:data] = data.map do |d|
        d.hash
      end
    end

    _hash
  end

  private
  def type(detail, options)
    @options = options

    case options[:type]
    when :sub
      @platform = detail.platform.name
    end
  end
end
