class CampaignsController < ApplicationController
  layout false, except: [:new, :edit, :clone, :index]

  def index
    respond_to do |format|
      format.html
      format.json {
        @campaigns = Campaign.get_user_campaign(current_user, params)
        @count = @campaigns.count

        start = params[:start].to_i
        limit = params[:limit].to_i

        @campaigns = @campaigns.offset(start).limit(limit)
      }
    end
  end

  def new
    @campaign = current_user.campaigns.find_by(is_draft: true) || Campaign.new
    respond_to do |format|
      format.html
    end
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end

  def clone
    # Clone Campaign info
    target_campaign = if current_user.is_admin?
                        Campaign.find(params[:id])
                      else
                        current_user.campaigns.find(params[:id])
                      end
    @campaign = CampaignService.clone(current_campaign, target_campaign, current_user)
  end

  def show
  end

  def steps
  end

  def step1
  end

  def step3

  end


  def step2
    if session[:creative_images].nil?
      session[:creative_images] = []
    end
  end

  def step4
  end

  private

  def set_campaign
    @campaign = current_user.campaigns.find(params[:id])
  end
end
