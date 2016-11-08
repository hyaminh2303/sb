class CampaignCityStatsController < ApplicationController
  include CampaignDetailsHelper

  def index
    _class = Reports::CampaignBy::AdminCityReport
    @campaign = Campaign.find(params[:campaign_id])

    respond_to do |format|
      format.json{
        @report = _class.new params
      }
    end
  end
end
