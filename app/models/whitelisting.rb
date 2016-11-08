require 'csv'
class Whitelisting < ActiveRecord::Base
  enum whitelist_type: [:device_platform_id]
  belongs_to :campaign
  validates :whitelist_type, presence: true

  mount_uploader :whitelist, WhitelistingUploader

  scope :devices, -> { find_by(whitelist_type: whitelist_types[:device_platform_id]) }
end
