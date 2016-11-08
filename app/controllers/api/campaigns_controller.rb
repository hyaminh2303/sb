class API::CampaignsController < API::ApplicationController
  before_filter :load_campaign, only: [:show, :launch, :edit, :pause, :cancel, :resume, :delete_campaign, :repare_tracking_data, :destroy, :remove_campaign_locations]

  def new

  end

  # def show
  # end

  def create
    @campaign = current_user.campaigns.build(update_params.merge(status: :pending))
    
    if @campaign.save
      render json: @campaign, serializer: CampaignSerializer
    else
      render json: {message: @campaign.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    campaign = Campaign.find params[:id]

    if CampaignService.update(campaign, current_user, update_params)
      render json: campaign, serializer: CampaignSerializer
    else
      Rails.logger.error(campaign.errors.full_messages)
      render json: { message: campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def get_current_step
    render json: {step: session[:campaign_new_current_step] || 1}
  end

  def save_current_step
    param! :step, Integer, default: 1, min: 1, max: 4
    session[:campaign_new_current_step] = params[:step]
    render json: {step: session[:campaign_new_current_step]}
  end

  def get_budget
    budget = Campaign.get_budget(params)
    render json: {budget: budget}
  end

  def launch
    render json: @campaign.launch_on(Platform.bidstalk)
  end

  def edit
    render json: @campaign.edit_on(Platform.bidstalk)
  end

  def cancel
    # session[:campaign_new_current_step] = 1
    #current_campaign.reset.save
    @campaign.destroy
    render json: {}
  end

  def pause
    CampaignService.pause(@campaign, current_user)
    render json: {status: @campaign.status, errors: @campaign.errors.full_messages}
  end

  def resume
    CampaignService.resume(@campaign, current_user)
    render json: {status: @campaign.status, errors: @campaign.errors.full_messages}
  end

  def destroy
    CampaignService.terminate(@campaign, current_user)
    render json: {}
  end

  def delete_campaign
    local_dsp_info = CampaignDspInfo.dsp_info @campaign
    local_data     = @campaign.daily_tracking_records
    if local_data.empty? && local_dsp_info.first.clicks == 0 && local_dsp_info.first.views == 0
      render json: @campaign.delete_on(Platform.bidstalk)
    else
      render json: {:base => ["The campaign already is in-used. It cannot be deleted!"]}
    end
  end

  def repare_tracking_data
    @campaign.delay.repare_tracking_data
    respond_with @campaign
  end

  def remove_campaign_locations
    locations = @campaign.campaign_locations
    locations.destroy_all
    render nothing: true
  end

  def past_campaigns
    campaigns = Campaign.past_campaigns_have_impressions(current_user, params)
    render json: campaigns, each_serializer: CampaignSerializer
  end

  private

  def update_params
    params[:campaign][:campaign_locations] ||= []
    permitted = params.require(:campaign).permit(:id, :name, :ad_domain, :banner_type_id, :category_id, :country_id, :timezone_id, :start_time, :end_time, :target_city, :pricing_model, :price, :target, :budget, :allow_bid_optimization, :cities_radius, gender_ids: [], age_range_ids: [], interest_ids: [], operating_system_ids: [], category_ids: [], city_ids: [], target_campaign_ids: [])
    locations_params = params.require(:campaign).permit(campaign_locations: [:id, :name, :radius, :latitude, :longitude, :campaign_id, :_destroy])
    permitted[:campaign_locations_attributes] = locations_params[:campaign_locations]
    permitted
  end

  #
  # Params for inherited resource
  #
  def widget_params
    params[:campaign][:campaign_locations] ||= []
    params[:campaign][:banners] ||= []
    params[:campaign][:age_ranges] ||= []
    params[:campaign][:genders] ||= []
    params[:campaign][:interests] ||= []
    params[:campaign][:operating_systems] ||= []
    params[:campaign][:categories] ||= []

    params.require(:campaign).permit(:id, :name, :ad_domain, :banner_type_id, :category_id, :country_id, :timezone_id, :start_time, :end_time, :pricing_model, :price, :target, :budget,
                             :gender_ids => [], :age_range_ids => [], :interest_ids => [], :operating_system_ids => [], :category_ids => [])

  end

  def load_campaign
    @campaign =   if current_user.is_admin?
                    Campaign.find(params[:id])
                  else
                    current_user.campaigns.find(params[:id])
                  end
  end
end
