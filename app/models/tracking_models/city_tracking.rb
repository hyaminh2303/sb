class TrackingModels::CityTracking < ActiveRecord::Base
  belongs_to :banner
  belongs_to :campaign
  belongs_to :city
end
