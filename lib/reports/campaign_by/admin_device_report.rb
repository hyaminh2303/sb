class Reports::CampaignBy::AdminDeviceReport
  include Reports::Campaigns::DeviceReport

  def initialize(options)
    init_report(options)
    @data = @campaign_details.map do |detail|
      Reports::Models::AdminDevice.new detail, @campaign
    end unless options[:skip_details]
    
    @total = Reports::Models::AdminDeviceTotal.new @campaign_details, @campaign
  end

  def template_name
    'admin_by_device'
  end
end
