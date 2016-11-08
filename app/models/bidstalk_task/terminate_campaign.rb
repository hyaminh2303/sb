class BidstalkTask::TerminateCampaign < BidstalkTask
  protected

  def run
    campaign.order.terminate_campaign
    if campaign.errors.empty?
      update(done: true)
      true
    else
      update(message: campaign.errors.full_messages.join("\n"))
      false
    end
  end
end