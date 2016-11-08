class API::BannersController < API::ApplicationController

  #
  # Upload image from client side and store it as a temp image.
  #
  # POST /api/banners/upload
  #
  # @param [Array] banners
  # @option banners [String] name
  # @option banners [String] landing_url
  # @option banners [File] image
  #
  def upload
    banners = upload_params[:banners_attributes]
    if banners.length > 0
      campaign_id = banners[0][:campaign_id]
      campaign = Campaign.find campaign_id
      campaign.update upload_params
    end
    render json: campaign.banners
  end

  private

  #
  # Upload params
  #
  # @return [Array] banners
  #
  def upload_params
    permitted = params.permit(banners: [:id, :name, :landing_url, :image, :campaign_id, :_destroy])
    {banners_attributes: permitted[:banners]}
  end

end
