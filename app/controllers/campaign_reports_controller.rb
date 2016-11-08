require 'csv'

class CampaignReportsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:export_device_id]
  def export
    campaign_id = params[:id]
    if current_user.has_role? :admin
      daily = Reports::CampaignBy::AdminDailyReport.new campaign_id: campaign_id, user: current_user
      location = Reports::CampaignBy::AdminLocationReport.new campaign_id: campaign_id
      os = Reports::CampaignBy::AdminOsReport.new campaign_id: campaign_id
      creative = Reports::CampaignBy::AdminCreativeReport.new campaign_id: campaign_id
      carrier = Reports::CampaignBy::AdminCarrierReport.new campaign_id: campaign_id
      device = Reports::CampaignBy::AdminDeviceReport.new campaign_id: campaign_id
      #   app =   Reports::CampaignBy::AdminAppReport.new               campaign_id: campaign_id
      #   group =     Reports::CampaignBy::AdminGroupReport.new       campaign_id: campaign_id, order: { '0' => { column: 0}}
      # Response to excel
      render xlsx: 'campaign_report', filename: daily.get_filename, locals: {
                                      daily_report: daily,
                                      location_report: location,
                                      os_report: os,
                                      # group_report: group,
                                      creative_report: creative,
                                      device_report: device,
                                      # app_report: app,
                                      carrier_report: carrier
                                    }
    else
      export_as_agency
    end

  end

  def export_as_agency
    campaign_id = params[:id]
    daily = Reports::CampaignBy::AgencyDailyReport.new campaign_id: campaign_id
    location = Reports::CampaignBy::AgencyLocationReport.new campaign_id: campaign_id
    os = Reports::CampaignBy::AgencyOsReport.new campaign_id: campaign_id
    creative = Reports::CampaignBy::AgencyCreativeReport.new campaign_id: campaign_id
    carrier = Reports::CampaignBy::AgencyCarrierReport.new campaign_id: campaign_id
    # group =     Reports::CampaignBy::AgencyGroupReport.new      campaign_id: campaign_id, order: { '0' => { column: 0}}
    # device      =  Reports::CampaignBy::AgencyDeviceReport.new     campaign_id: campaign_id
    # Response to excel
    render xlsx: 'campaign_report', filename: daily.get_filename, locals: {
                                    daily_report: daily,
                                    location_report: location,
                                    creative_report: creative,
                                    os_report: os,
                                    carrier_report: carrier,
                                    device_report: nil
                                  }
  end

  def export_device_id
    campaign = Campaign.find params[:id]
    daily_trackings = DailyTrackingRecord.where(campaign_id: params[:id])
    data = daily_trackings.reduce([]) { |result, tracking| result + tracking.devices }
    data = data.select { |d| !d.blank? }
    file = CSV.generate(headers: true) do |csv|
      data.each do |d|
        csv << [d]
      end
    end

    send_data file, filename: "#{campaign.name.downcase.gsub(' ', '_')}_devideID_#{Time.now.strftime Date::DATE_FORMATS[:iso]}.csv"

  end
end
