class WhitelistService
  class << self
    def generate_csv(campaign)
      daily_trackings = DailyTrackingRecord.select(:id, :devices)
                          .where(campaign_id: campaign.target_campaign_ids)

      return nil if daily_trackings.blank?

      data = daily_trackings.reduce([]) { |result, tracking| result + tracking.devices }

      file = Tempfile.new([ "device-platform-id-#{campaign.id}", '.csv' ])
      CSV.open(file, "wb") do |csv|
        data.each do |d|
          csv << [d]
        end
      end
      file
    end
  end
end