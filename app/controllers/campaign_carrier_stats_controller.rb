class CampaignCarrierStatsController < ApplicationController
  include CampaignDetailsHelper

  before_action :set_campaign

  def index
    # if can? :manage, Campaign
    _class = Reports::CampaignBy::AdminCarrierReport
    # else
    #   _class = Reports::CampaignBy::AdminCarrierReport
    # end

    if params[:format] == 'json'
      @report = _class.new params
    end
  end

  private
  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end
end
