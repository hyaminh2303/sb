class LocationTrackingRecord < ActiveRecord::Base

  # region Associations

  belongs_to :banner
  belongs_to :campaign_location
  belongs_to :campaign

  # endregion

end
