class API::TypesController < API::ApplicationController

  def index
    @types = CampaignType.all
    respond_with(@types)
  end

end
