class Reports::CampaignBy::AgencyDeviceReport
  include Reports::Campaigns::DeviceReport

  def initialize(options)
    init_report(options)

    @data = @campaign_details.map do |detail|
      Reports::Models::AgencyDevice.new detail, @campaign
    end unless options[:skip_details]

    @total = Reports::Models::AgencyDeviceTotal.new @campaign_details, @campaign
  end

  def template_name
    'agency_by_device'
  end
end
