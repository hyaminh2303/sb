class CampaignLocation < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :campaign

  validates :name, :latitude, :longitude, :radius, :presence => true
  validates :latitude, :numericality => { :greater_than_or_equal_to => -90, :less_than_or_equal_to => 90 }
  validates :longitude, :numericality => { :greater_than_or_equal_to => -180, :less_than_or_equal_to => 180 }
  validates :name, :key, length: {:maximum => 255}
  
  before_save :generate_key

  def self.save_by_campaign (campaign_id, locations)
    if campaign_id && locations && locations.length > 0
      CampaignLocation.delete_by_campaign(campaign_id)
      locations.each { |location|
        entity = CampaignLocation.new(location)
        entity.campaign_id = campaign_id
        entity.save
      }
    end
  end

  def self.delete_by_campaign (campaign_id)
    CampaignLocation.delete_all({campaign_id: campaign_id})
  end

  private

  def generate_key
    self.key = SecureRandom.hex(8) if self.key.blank?
  end
end
