require 'rails_helper'

shared_context :fake_tracking_data do
  before(:all) do

    FactoryGirl.build(:campaign_1).save(validate: false)
    FactoryGirl.build(:order_1).save(validate: false)
    FactoryGirl.build(:creative_1).save(validate: false)
    FactoryGirl.build(:creative_2).save(validate: false)
    FactoryGirl.build(:campaign_location_1).save(validate: false)
    FactoryGirl.build(:campaign_location_2).save(validate: false)
    FactoryGirl.build(:daily_tracking_1).save(validate: false)
    FactoryGirl.build(:location_tracking_1).save(validate: false)

    creative_key          = 11
    campaign_location_key = 1
    date                  = Time.now.strftime(Date::DATE_FORMATS[:number])
    @view                 = 5
    @click                = 3

    @redis_client = RedisClient.new

    @redis_client.set_tracking_impression(creative_key, campaign_location_key, date, @view)
    @redis_client.set_tracking_click(creative_key, campaign_location_key, date, @click)
    @redis_client.set_tracking_impression(creative_key+1, campaign_location_key, date, @view)
    @redis_client.set_tracking_click(creative_key+1, campaign_location_key+1, date, @click)

    creative = Banner.find_by_key(creative_key)
    campaign = creative.campaign

    @daily_tracking_info = {
        dsp_id:      campaign.order.dsp_id,
        order_id:    campaign.order.id,
        campaign_id: campaign.id,
        banner_id: creative.id,
        date:        Date.today
    }

    @daily_tracking = DailyTrackingRecord.find_by(@daily_tracking_info)

    campaign_location = CampaignLocation.find_by_key(campaign_location_key)

    @location_tracking_info = {
        banner_id:          creative.id,
        campaign_location_id: campaign_location.id,
        date:                 Date.today
    }

    @location_tracking = LocationTrackingRecord.find_by(@location_tracking_info)
  end
end
