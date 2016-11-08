
class Order < ActiveRecord::Base

  # region Associations

  belongs_to :campaign
  belongs_to :platform, foreign_key: 'dsp_id'

  # endregion

  def get_details
    platform_campaign.get
  end

  #
  # create campaign & create creative on specific platform
  # @todo not handler errors yet
  # @return [Hash] campaign on specific platform
  #
  def launch_campaign
    campaign_info = platform_campaign.create
    if campaign_info.present?
      self.dsp_campaign_id = campaign_info[:id]
    end
    campaign_info
  end

  #
  # update campaign & creative on specific platform
  # @todo not handler errors yet
  # @return [Hash] campaign on specific platform
  #
  def edit_campaign
    campaign_info = platform_campaign.edit
    # if campaign_info.present?
    #   platform_campaign.delete_creative
    #   platform_campaign.save_creative
    # end
    campaign_info
  end

  #
  # pause campaign on specific platform
  # @return [Hash] {:campaign_id, :campaign_title, :campaign_status}
  #
  def pause_campaign
    platform_campaign.pause
  end

  #
  # resume campaign on specific platform
  # @return [Hash] {:campaign_id, :campaign_title, :campaign_status}
  #
  def resume_campaign
    platform_campaign.resume
  end

  def terminate_campaign
    platform_campaign.delete_campaign
  end

  def get_report(start_date, end_date)
    campaign_info = platform_campaign.get_report(start_date, end_date)
    campaign_info
  end

  private

  def platform_campaign
    class_name = "#{platform.name.classify}Models::Campaign"
    @platform_campaign = class_name.classify.constantize.new campaign unless (@platform_campaign.present? && @platform_campaign.class == class_name)
    @platform_campaign
  end

end
