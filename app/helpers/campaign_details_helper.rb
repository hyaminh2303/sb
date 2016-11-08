module CampaignDetailsHelper
  def get_exchange_rate(campaign)
    campaign.exchange_rate.nil? ? MoneyRails.default_bank.get_rate(@campaign.unit_price_currency, Money.default_currency) : campaign.exchange_rate
  end

  def check_agency
    unless can?(:manage, Campaign)
      # Get acency id
      agency = current_user.agency

      unless agency.nil?
        if agency.is_client? and @campaign.agency_id != agency.id
          redirect_to root_path
          return
        end

        unless @campaign.agency_id == agency.id or @campaign.agency.parent_id == agency.id
          redirect_to root_path
          return
        end
      end

    end
  end
end
