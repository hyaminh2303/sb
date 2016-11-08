class CampaignExchangeStatsController < ApplicationController
  include CampaignDetailsHelper

  before_action :set_campaign

  def index
    _class = Reports::CampaignBy::AdminExchangeReport

    if params[:format] == 'json'
      @report = _class.new params
    end

  end

  private
  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end
end
