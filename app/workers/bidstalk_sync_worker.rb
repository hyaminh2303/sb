class BidstalkSyncWorker
  include Sidekiq::Worker

  def perform
    BidstalkTask.not_done.each(&:execute)
  end
end