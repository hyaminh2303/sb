class CampaignMailLogger < ApplicationDecorator
  alias_method :campaign, :instance

  def initialize(_campaign, user = nil)
    super(_campaign)
    @user = user
    @user_id = user.nil? ? nil : user.id
    subscribe_events
  end

  private

  def subscribe_events
    campaign.on(:resume_automatically){
      WorkerMailer.resume_campaign(campaign, Time.now).deliver
    }

    campaign.on(:pause_due_to_over_delivery){
      WorkerMailer.over_delivery(campaign).deliver
    }

    campaign.on(:pause_due_to_over_budget){
      WorkerMailer.over_budget(campaign).deliver
    }

    campaign.on(:increase_maxbid){
      WorkerMailer.increase_maxbid(campaign, Time.now).deliver
    }

    campaign.on(:pause_manually){
      CampaignNotifier.delay.pause(campaign)
    }

    campaign.on(:terminate){
      CampaignNotifier.delay.terminated_on(campaign)
    }

    campaign.on(:update){
      CampaignNotifier.delay.edit_on(campaign.id, campaign.previous_changes)
    }

    campaign.on(:pause_failed){
      CampaignNotifier.delay.pause_failed(campaign.id, @user_id)
    }

    campaign.on(:resume_failed){
      CampaignNotifier.delay.resume_failed(campaign.id, @user_id)
    }

    campaign.on(:update_failed){
      CampaignNotifier.delay.error_updating(campaign.id, campaign.errors.full_messages)
    }

    campaign.on(:terminate_failed){
      CampaignNotifier.delay.terminate_failed(campaign.id, @user_id)
    }
  end
end