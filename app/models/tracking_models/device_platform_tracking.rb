module TrackingModels
  class DevicePlatformTracking < ActiveRecord::Base
    belongs_to :campaign
    belongs_to :banner
    validates :date, presence: true
    # validate :date_between_campaign_start_end

    # validate :unique_log

    scope :by_date, ->(date) { where(date: date)}
    scope :select_by_campaign, ->(campaign_id) { where(campaign_id: campaign_id) if campaign_id.to_i > 0 }
    scope :select_device_id, ->(campaign_id, select_by, group_by) { select(select_by).where(campaign_id: campaign_id).group(group_by) }
    scope :select_in_period, ->(start_date, end_date) { where(date: start_date..end_date) }
    # scope :belong_to, ->(user) { joins(:campaign).where(campaigns: {agency_id: user.agency.id}) if (user.present? && user.is_agency_or_client?)}

    #------------------------------- begin instances ---------------------------------#
    # Custom validation
    def unique_log
      if self.new_record?
        unless self.class.where(:campaign_id => campaign_id, :date => date, :name => name, banner_id: banner_id).count == 0
          errors.add(:device_platform_tracking, I18n.t('models.device_platform_tracking.validate.already_add'))
        end
      end
    end

    # validate date
    def date_between_campaign_start_end
      if date.nil? || date < campaign.start_time || date > campaign.end_time
        errors.add(:campaign, I18n.t('models.device_platform_tracking.validate.not_running_date'))
      end
    end
  end
end
