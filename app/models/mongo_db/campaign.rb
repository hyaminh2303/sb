module MongoDb
  class Campaign
    include Mongoid::Document
    store_in collection: 'campaigns'

    field :campaign_id, type: Integer
    field :start_time, type: Time
    field :end_time, type: Time
    field :status, type: String
    field :locations, type: Array
    field :cities, type: Array
    field :creatives, type: Array
    field :city_targeting, type: Boolean, default: false
    field :is_draft, type: Boolean

    def self.sync(params)
      MongoDb::Location.where(campaign_id: params.id).delete_all
      params.campaign_locations.each do |location|
        MongoDb::Location.create(campaign_id: params.id,
                                campaign_location_id: location.id,
                                location: [location.latitude, location.longitude],
                                radius: location.radius)
      end

      cities = params.campaign_locations.map { |c| {name: c.name} }
      creatives = params.banners.with_deleted.map { |b| {id: b.id, key: b.key} }

      data = {
          campaign_id: params.id,
          start_time: params.start_time,
          end_time: params.end_time,
          status: params.status,
          city_targeting: params.target_city,
          is_draft: params.is_draft,
          creatives: creatives,
          # locations: locations,
          cities: cities
      }
      campaign = self.find_by(campaign_id: params.id)

      if campaign
        campaign.update_attributes!(data)
      else
        self.create!(data)
      end
    end
  end
end