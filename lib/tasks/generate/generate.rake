namespace :generate do
  desc "Generate sample banners, campaign & daily tracking record"
  task sample_data: :environment do

    Campaign.destroy_all
    Banner.delete_all
    Order.destroy_all
    DailyTrackingRecord.destroy_all

    b1 = create_banner 'Banner 1', 'creative_320x50.jpg', 'http://pepsi.com/c'
    b2 = create_banner 'Banner 2', 'creative_320x50.jpg', 'http://pepsi.com/c?opt=2'

    puts 'Create 2 banners done.'

    c = create_campaign 'Pepsi', 'http://pepsi.com', Date.today.to_time, Date.today.to_time + 30, [b1, b2]

    puts 'Create campaign done.'

    o = create_order c.id

    puts 'Create order done.'

    (Date.today..Date.today + 30).to_a.each do |date|
      create_daily_tracking_record date, c, b1, o
      create_daily_tracking_record date, c, b2, o
    end

    puts 'Create daily tracking records done.'
  end

  private

  def create_banner(name, filename, landing_url)
    Banner.create({name: name, landing_url: landing_url, image: File.open("#{File.dirname(__FILE__)}/banners/#{filename}")})
  end

  def create_campaign(name, ad_domain, start_time, end_time, banners = [])
    c = Campaign.new
    c.save validate: false
    c.update name: name,
             ad_domain: ad_domain,
             category_id: 130,
             country_id: 223,
             timezone_id: 23,
             pricing_model: 2,
             price: rand(1..10).to_money(:USD),
             target: rand(100..10000),
             start_time: start_time,
             end_time: end_time,
             user_id: 1,
             is_draft: 0,
             banner_type_id: 1,
             banners: banners
    c
  end

  def create_order(campaign_id)
    Order.create({
                     campaign_id: campaign_id,
                     dsp_id: 2, # Bidstalk
                     dsp_campaign_id: rand(1000..9999)
                 })
  end

  def create_daily_tracking_record(date, campaign, banner, order)
    DailyTrackingRecord.create({
                                   banner_id: banner.id,
                                   order_id: order.id,
                                   campaign_id: campaign.id,
                                   dsp_id: 2,
                                   views: rand(10..500),
                                   clicks: rand(10..50),
                                   date: date
                               })
  end

end
