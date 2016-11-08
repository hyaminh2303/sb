class BidstalkTask < ActiveRecord::Base
  belongs_to :campaign
  scope :not_done, -> { where(done: false)
                            .joins(:campaign)
                            .where('sb_campaigns.start_time <= ? AND sb_campaigns.end_time >= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day) }

  delegate :name, to: :campaign, prefix: true, allow_nil: true

  def execute
    info = campaign.order.get_details
    status = info[:status]
    return false unless status

    if %w(REJECTED DELETED).include?(status)
      self.destroy
      true
    else
      run
    end
  end
end
