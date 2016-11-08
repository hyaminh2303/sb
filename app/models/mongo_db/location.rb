module MongoDb
  class Location
    include Mongoid::Document
    store_in collection: :locations

    field :campaign_id, type: Integer
    field :campaign_location_id, type: Integer
    field :location, type: Array
    field :radius, type: Float

    index({ location: '2d', campaign_id: 1 })
  end
end