class CampaignOptimization
  MAX_BID_INCREASE_STEP = 0.05

  def initialize(campaign)
    @campaign = campaign
  end

  def optimize_pause_yesterday
    if @campaign.get_remaining_budget > 0 && @campaign.paused? &&
      @campaign.force_pause_yesterday? && !@campaign.over_delivery? &&
      @campaign.paused_by_optimization?

      CampaignService.resume(@campaign)
      @campaign.publish(:resume_automatically)
    end
  end

  def optimize_over_delivery
    if @campaign.get_remaining_budget > 0 && !@campaign.paused? && @campaign.over_delivery?
      CampaignService.pause(@campaign)
      @campaign.publish(:pause_due_to_over_delivery)
    end
  end

  def optimize_over_budget
    if @campaign.get_remaining_budget <= 0 && !@campaign.paused?
      CampaignService.pause(@campaign)
      @campaign.publish(:pause_due_to_over_budget)
    end
  end

  def optimize_under_delivery
    if !@campaign.paused? && @campaign.yesterday_under_delivery?
      increase_maxbid
      @campaign.publish(:increase_maxbid)
    end
  end

  private

  def increase_maxbid
    dsp_campaign = get_platform_campaign
    info = dsp_campaign.get
    update_params = {
      max_bid: info[:max_bid].to_f + MAX_BID_INCREASE_STEP
    }
    dsp_campaign.edit update_params
  end

  def get_platform_campaign
    class_name = "#{@campaign.order.platform.name}Models::Campaign"
    class_name.classify.constantize.new @campaign
  end
end