class API::CountriesController < API::ApplicationController

  def index
    @countries = Country.order(name: :asc)
    respond_with(@countries)
  end

  protected
  def collection
    Country.valid_countries
  end

end
