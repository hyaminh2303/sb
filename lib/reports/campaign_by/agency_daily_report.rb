class Reports::CampaignBy::AgencyDailyReport
  include Reports::Campaigns::DateReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AgencyCampaign.new detail, @campaign
    end

    @total = Reports::Models::AgencyCampaignTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_date'
  end
end
