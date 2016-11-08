class API::CompaniesController <  API::ApplicationController
  def index
    @companies = User.uniq.pluck(:company)
    render json: @companies
  end
end