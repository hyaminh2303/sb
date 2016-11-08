module PlatformMapping
  extend ActiveSupport::Concern
  module ClassMethods
    def get_platform_campaign_info(campaign)
      class_name = "#{campaign.order.platform.name}Models::Campaign"
      @platform_campaign = class_name.classify.constantize.new campaign unless (@platform_campaign.present? && @platform_campaign.class == class_name)
      @platform_campaign.get
    end
  end
end