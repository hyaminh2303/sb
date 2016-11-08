module MongoDb
  class Event
    include Mongoid::Document
    store_in collection: :events

    field :timestamp, type: Time
    field :creative_id, type: String
    field :event_type, type: String
    field :exchange_name, type: String
  end
end