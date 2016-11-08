class CampaignCreativeStatsController < ApplicationController
  include CampaignDetailsHelper

  before_action :set_campaign
  # before_action :check_agency

  def index
    # if can? :manage, Campaign
      _class = Reports::CampaignBy::AdminCreativeReport
    # else
    #   _class = Reports::CampaignBy::AgencyCreativeReport
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
