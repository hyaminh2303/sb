class CampaignDetailsController < ApplicationController
  def detail
  end

  def index
    params[:user] = current_user
    @campaign = Campaign.find(params[:campaign_id])
    _class = Reports::CampaignBy::AdminDailyReport
    _os_class = Reports::CampaignBy::AdminOsReport
    _creative_class = Reports::CampaignBy::AdminCreativeReport
    _carrier_class = Reports::CampaignBy::AdminCarrierReport
    _app_class = Reports::CampaignBy::AdminAppReport
    _location_class = Reports::CampaignBy::AdminLocationReport
    _device_class = Reports::CampaignBy::AdminDeviceReport
    _exchange_class = Reports::CampaignBy::AdminExchangeReport

    if params[:format] == 'json'
      @report = _class.new params
    else
      @report = _class.new params.merge(skip_details: true)
    end
    @os_report = _os_class.new params
    @creative_report = _creative_class.new params
    @carrier_report = _carrier_class.new params
    @app_report = _app_class.new params
    @location_report = _location_class.new params
    @device_report = _device_class.new params
    @exchange_report = _exchange_class.new params
  end
end
