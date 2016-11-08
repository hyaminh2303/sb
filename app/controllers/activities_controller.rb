class ActivitiesController < ApplicationController
  def index
    @target = Campaign.find_by_id(params[:campaign_id])
    @activities = @target ? @target.activities.order(created_at: :desc) : []
  end
end