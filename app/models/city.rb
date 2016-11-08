class City < ActiveRecord::Base
  DEFAULT_RADIUS = 10000.0
  belongs_to :country
  include DspMapping
  has_dsp_mapping

  has_many :tracking_models_city_trackings, class_name: 'TrackingModels::CityTracking', dependent: :delete_all

  scope :have_latitude_and_longitude, -> { where.not(latitude: nil, longitude: nil) }
  scope :get_by_country, -> (country_id) { where(country_id: country_id) }

  class << self
    def filter_cities(params)
      cities = self.have_latitude_and_longitude
      cities = cities.get_by_country(params[:country_id]) if params[:country_id].present?
      cities
    end
  end
end
