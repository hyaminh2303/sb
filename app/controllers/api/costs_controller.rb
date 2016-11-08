class API::CostsController < API::ApplicationController
  def get_price
    country_id = params[:country_id]
    pricing_model = params[:pricing_model]
    cost = Cost.where({country_id: country_id, pricing_model: pricing_model}).first || Cost.new
    respond_with cost
  end
end
