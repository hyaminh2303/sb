class BidstalkTask::DeleteBanner < BidstalkTask
  belongs_to :banner, -> { with_deleted }
  delegate :name, to: :banner, prefix: true, allow_nil: true

  def run
    creative = BidstalkModels::Creative.new banner, campaign
    result = creative.delete
    if result[:creative_status] == 'DELETED'
      # if DailyTrackingRecord.exists?(banner_id: banner.id)
      update(done: true)
      true
      # else
      #   banner.really_destroy!
      #   self.destroy
      # end
    else
      false
    end
  end
end