class API::AdExchangesController < API::ApplicationController
  layout false

  def update_exchanges
    UpdateAdExchangeWorker.perform_async
    render nothing: true, status: 200
  end
end
