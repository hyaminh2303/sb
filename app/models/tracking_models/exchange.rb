class TrackingModels::Exchange < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :banner
  validates :date, presence: true

end
