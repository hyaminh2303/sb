class BidstalkTask::PauseCampaign < BidstalkTask

  protected

  def run
    info = campaign.order.get_details
    if info && info[:status] == 'RUNNING'
      campaign.order.pause_campaign
      if campaign.errors.empty?
        update(done: true)
        true
      else
        update(message: campaign.errors.full_messages.join("\n"))
        false
      end
    else
      update(done: true)
    end
  end
end