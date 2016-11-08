class Banner < ActiveRecord::Base
  include Bidstalk::Creative
  acts_as_paranoid

  ACCEPTED_DIMENSIONS = [
    { width: 300, height: 250 },
    { width: 300, height: 50 },
    { width: 320, height: 50 },
    { width: 728, height: 90 }
  ]

  ACCEPTED_DIMENSIONS_ADMIN = {width: 320, height: 480}

  # region CarrierWave mounting

  mount_uploader :image , BannerUploader

  # endregion

  # region Custom Attributes

  attr_accessor :random_uuid

  # endregion

  # region Associations

  belongs_to :campaign
  has_many :location_tracking_records
  has_many :device_os_trackings, :class_name => 'TrackingModels::OsTracking'#, :dependent => :delete_all
  has_many :carrier_trackings, :class_name => 'TrackingModels::CarrierTracking'#, :dependent => :delete_all
  has_many :device_platform_trackings, :class_name => 'TrackingModels::DevicePlatformTracking'#, :dependent => :delete_all
  has_many :application_trackings#, :dependent => :delete_all
  has_many :creative_trackings#, :dependent => :delete_all


  # endregion

  # region Validation
  validates :name, :landing_url, :image, presence: true
  # TODO: need to be fixed
  validates :landing_url, url: true
  validates :name, :original_filename, length: {:maximum => 255}
  # validate :check_dimensions

  # endregion

  # region Callbacks

  after_initialize :generate_uuid
  before_save :generate_key

  # endregion

  # region Private Methods

  private

  def generate_uuid
    self.random_uuid = SecureRandom.uuid
  end

  def generate_key
    self.key = SecureRandom.hex(8) if self.key.blank?
  end

  def check_dimensions
    return if image_cache.nil?

    is_admin = self.campaign.user.is_admin?
    ACCEPTED_DIMENSIONS.push( ACCEPTED_DIMENSIONS_ADMIN ) if is_admin
    banner_dimension = {width: image.width, height: image.height}
    errors.add :image, "Your image is invalid." unless ACCEPTED_DIMENSIONS.include?(banner_dimension)
  end

  # endregion
end
