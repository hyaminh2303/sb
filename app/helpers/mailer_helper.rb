module MailerHelper
  def get_unit_budget(campaign)
    Money.new(campaign.budget_cents, campaign.budget_currency)
  end

  def date_change?(old_date, new_date)
    old_date.to_date != new_date.to_date
  end
end