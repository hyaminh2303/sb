require 'faker'

FactoryGirl.define do
  factory :campaign_1, class: Campaign do
    name Faker::App.name
    ad_domain Faker::Internet.domain_name
    category_id 0
  end

  factory :order_1, class: Order do
    campaign_id 1
    dsp_id 2
    dsp_campaign_id 1
  end

  factory :creative_1, class: Banner do
    campaign_id 1
    key 11
  end

  factory :creative_2, class: Banner do
    campaign_id 1
    key 12
  end

  factory :campaign_location_1, class: CampaignLocation do
    key 1
  end

  factory :campaign_location_2, class: CampaignLocation do
    key 2
  end

  factory :daily_tracking_1, class: DailyTrackingRecord do
    campaign_id 1
    dsp_id 2
    banner_id 1
    order_id 1
    views 7
    clicks 5
    date Time.now.strftime(Date::DATE_FORMATS[:number])
  end

  factory :location_tracking_1, class: LocationTrackingRecord do
    campaign_location_id 1
    banner_id 1
    views 3
    clicks 1
    date Time.now.strftime(Date::DATE_FORMATS[:number])
  end
end