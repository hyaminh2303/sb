class CampaignLocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :latitude, :longitude, :radius, :campaign_id
end
