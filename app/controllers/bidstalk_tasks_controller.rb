class BidstalkTasksController < ApplicationController
  def index
    @tasks = BidstalkTask.not_done
  end
end