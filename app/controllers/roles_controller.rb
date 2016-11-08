class RolesController < ApplicationController
  load_and_authorize_resource

  def index
    @roles = Role.order(name: :asc)
    render json: @roles
  end
end