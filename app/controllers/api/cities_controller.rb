class API::CitiesController <  API::ApplicationController
  def index
    @cities = City.filter_cities(params)
    render json: @cities, each_serializer: CitySerializer
  end
end