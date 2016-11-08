class UpdateAdExchangeWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    AdExchange.update_ad_exchange
  end

end