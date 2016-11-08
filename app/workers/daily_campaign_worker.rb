class DailyCampaignWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    $allow_send_message = true
    run_at = Time.now 
    action = 'Refund budget'     
    complete_campaigns = Campaign.published_campaigns.yesterday_completed_campaigns.client_campaigns
    complete_campaigns.each do |campaign|
      begin
        if campaign.get_remaining_budget > 0
          ActiveRecord::Base.transaction do
            remaining_budget_without_cents = campaign.get_remaining_budget/100.0
            user = campaign.user
            user_budget_after_refund = user.budget + remaining_budget_without_cents
            user.update(budget: user_budget_after_refund)
            WorkerMailer.refund_budget(campaign, run_at).deliver
            campaign.create_activity(Campaign::ActivityType::REFUND,
                                     parameters: { amount: remaining_budget_without_cents })
          end
        end
      rescue StandardError => e
        WorkerMailer.error_worker("#{self.class.name}: #{action}", run_at, e, campaign).deliver
        raise e
      end
    end
  end
end