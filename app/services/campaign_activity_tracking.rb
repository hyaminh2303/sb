class CampaignActivityTracking < ApplicationDecorator
  alias_method :campaign, :instance

  def initialize(_campaign, user = nil)
    super(_campaign)
    @user = user
    subscribe_events
  end

  def update(params)
    result = campaign.update(params)
    if result
      track_budget_change
      track_date_change unless campaign.is_draft
    end

    result
  end

  private

  def track_budget_change
    changes = campaign.previous_changes
    return unless changes[:budget_cents]

    campaign.create_activity Campaign::ActivityType::BUDGET_CHANGED,
                             parameters: {old_amount: changes[:budget_cents][0]/100,
                                          new_amount: changes[:budget_cents][1]/100},
                             owner: @user
  end

  def track_date_change
    changes = campaign.previous_changes
    if changes[:start_time] || changes[:end_time]
      params = {}

      if changes[:start_time] && changes[:start_time][0].to_date != changes[:start_time][1].to_date
        params[:old_start_time] = changes[:start_time][0]
        params[:new_start_time] = changes[:start_time][1]
      end

      if changes[:end_time] && changes[:end_time][0].to_date != changes[:end_time][1].to_date
        params[:old_end_time] = changes[:end_time][0]
        params[:new_end_time] = changes[:end_time][1]
      end

      campaign.create_activity(Campaign::ActivityType::DATE_CHANGED,
                               parameters: params,
                               owner: @user) unless params.empty?
    end
  end

  def subscribe_events
    campaign.on(:resume_automatically) {
      campaign.create_activity Campaign::ActivityType::RESUME_AUTOMATICALLY,
                               parameters: {delivery_realized: campaign.delivery_realized,
                                            delivery_expected: campaign.delivery_expected}
    }

    campaign.on(:pause_due_to_over_delivery) {
      campaign.create_activity Campaign::ActivityType::PAUSE_DUE_TO_OVER_DELIVERY,
                               parameters: {delivery_realized: campaign.delivery_realized,
                                            delivery_expected: campaign.delivery_expected}
    }

    campaign.on(:pause_due_to_over_budget) {
      campaign.create_activity Campaign::ActivityType::PAUSE_DUE_TO_OVER_BUDGET
    }

    campaign.on(:increase_maxbid) {
      campaign.create_activity Campaign::ActivityType::INCREASE_MAXBID
    }

    campaign.on(:pause_manually) {
      campaign.create_activity Campaign::ActivityType::PAUSE_MANUALLY, owner: @user
    }

    campaign.on(:pause_failed) {
      campaign.create_activity Campaign::ActivityType::PAUSE_MANUALLY, owner: @user
    }

    campaign.on(:resume_manually) {
      campaign.create_activity Campaign::ActivityType::RESUME_MANUALLY, owner: @user
    }

    campaign.on(:resume_failed) {
      campaign.create_activity Campaign::ActivityType::RESUME_MANUALLY, owner: @user
    }

    campaign.on(:terminate) {
      campaign.create_activity Campaign::ActivityType::TERMINATE, owner: @user
    }

    campaign.on(:terminate_failed) {
      campaign.create_activity Campaign::ActivityType::TERMINATE, owner: @user
    }
  end
end