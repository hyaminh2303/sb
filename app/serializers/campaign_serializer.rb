class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :name, :ad_domain, :start_time, :end_time, :pricing_model, :price, :target,
             :country_id, :country_code, :category_id, :category_id, :timezone_id,
             :genders, :age_ranges, :interests, :operating_systems, :locations, :banners, :is_draft, :categories, :allow_bid_optimization, :budget, :cities, :target_city,
             :city_ids, :cities_radius, :operating_system_ids, :gender_ids, :category_ids, :target_campaign_ids, :status, :has_tracking_data

  def status
    object.current_status!
  end

  def country_code
    object.country.country_code
  end

  def price
    object.price.dollars
  end

  def locations
    object.campaign_locations
  end

  def budget
    object.budget.to_f
  end

  def end_time 
    object.end_time.beginning_of_day
  end

  def start_time 
    object.start_time.beginning_of_day
  end

  # has_one :banner_type
  # has_one :country
  # has_one :category
  # has_one :timezone
  has_many :locations
  has_many :banners
end
