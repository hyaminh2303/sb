class DeviceOsTracking < ActiveRecord::Base
  self.table_name = "#{self.table_name_prefix}os_trackings"
  belongs_to :banner
  belongs_to :campaign
  belongs_to :operating_system
end
