require 'warning_associated_validator'

class Campaign < ActiveRecord::Base
  include CampaignHealth
  include PublicActivity::Common
  include SelfBooking::Publisher

  enum pricing_model: Hash[CampaignType.pluck(:name, :id)]
  enum status: [:pending, :live, :paused, :completed, :terminated]
  # implicitly have price Money object
  monetize :price_cents
  # implicitly have budget Money object
  monetize :budget_cents

  serialize :target_campaign_ids, Array

  # region Association

  has_one :order, dependent: :delete

  attr_accessor :campaign_ids

  belongs_to :country
  belongs_to :timezone
  belongs_to :category
  belongs_to :campaign_type, foreign_key: :pricing_model
  belongs_to :banner_type
  belongs_to :user

  delegate :name, to: :user, prefix: true, allow_nil: true

  has_many :banners, dependent: :delete_all
  has_many :campaign_locations, dependent: :delete_all
  has_many :daily_tracking_records, dependent: :delete_all
  has_many :device_os_trackings, dependent: :delete_all
  has_many :application_trackings, dependent: :delete_all
  has_many :creative_trackings, dependent: :delete_all
  has_many :location_tracking_records, dependent: :delete_all
  has_many :tracking_models_carrier_trackings, class_name: 'TrackingModels::CarrierTracking', dependent: :delete_all
  has_many :tracking_models_device_trackings, class_name: 'TrackingModels::DevicePlatformTracking', dependent: :delete_all
  has_many :tracking_models_exchanges, class_name: 'TrackingModels::Exchange', dependent: :delete_all
  has_many :campaign_dsp_infos
  has_many :whitelistings, dependent: :destroy

  has_and_belongs_to_many :genders, join_table: 'sb_campaigns_genders'
  has_and_belongs_to_many :interests, join_table: 'sb_campaigns_interests'
  has_and_belongs_to_many :age_ranges, join_table: 'sb_campaigns_age_ranges'
  has_and_belongs_to_many :operating_systems, join_table: 'sb_campaigns_operating_systems'
  has_and_belongs_to_many :categories, join_table: 'sb_campaigns_categories'
  has_and_belongs_to_many :cities

  accepts_nested_attributes_for :banners, allow_destroy: true
  accepts_nested_attributes_for :campaign_locations, allow_destroy: true
  accepts_nested_attributes_for :daily_tracking_records, allow_destroy: true

  # endregion

  # region Validation

  validates :name, :ad_domain, :country, :timezone, :pricing_model, :banner_type, :start_time, :end_time, presence: true
  validates :name, :ad_domain, length: { maximum: 255 }
  validates_format_of :ad_domain, with:  /\Ahttp[s]?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?\z/ix

  validates :banners, presence: true, unless: :is_draft
  validates :campaign_locations, presence: true, if: :not_draft_and_not_target_city?

  validates_associated :banners, :campaign_locations

  validates :banners, length: { maximum: 50 }
  validates :campaign_locations, length: { maximum:100 }, if: Proc.new { |p| p.user.is_admin? && !p.target_city}
  validates :campaign_locations, length: { maximum:10 },   if: Proc.new { |p| !p.user.is_admin? && !p.target_city}
  validates :cities, presence: true, if: Proc.new { |p| !p.is_draft && p.target_city }
  validates :cities_radius, numericality: { greater_than_or_equal_to: 1}, if: Proc.new { |p| !p.is_draft && p.target_city }
  validate :user_budget, on: [:update, :create], if: Proc.new { |p| !p.user.is_admin? }
  # endregion

  # region Scope

  scope :launched, ->(user) do
    if user.has_role? :admin
      where(is_draft: false)
    else
      where(is_draft: false, user_id: user.id)
    end
  end

  scope :past_campaigns, -> { where('start_time <= ?', Time.now) }
  scope :have_impression, -> { joins(:daily_tracking_records) }
  scope :within_cities, -> (city_ids) { joins(:cities).where(sb_campaigns_cities: { city_id: city_ids }) }
  scope :in_country, -> (country_id) { where(country_id: country_id) }

  scope :by_company, ->(company) do
    if company == "ALL"
      where(is_draft: false)
    else
      where(:user_id => User.where(company: company).pluck(:id))
    end
  end

  def self.past_campaigns_have_impressions(user, params)
    campaigns = self.distinct.past_campaigns.launched(user).have_impression
    campaigns = campaigns.in_country(params[:country_id]) if params[:country_id].present?
    campaigns
  end

  scope :active_campaigns, -> (today_date) { where('start_time <= ? AND end_time >= ? AND terminated_at IS NULL', today_date, today_date) }

  scope :optimization_campaigns, -> { where(allow_bid_optimization: true) }

  scope :yesterday_completed_campaigns, -> { where('(terminated_at >= ? AND terminated_at <= ?) OR (end_time >= ? AND end_time <= ?)',
                                                   Date.yesterday.beginning_of_day,
                                                   Date.yesterday.end_of_day,
                                                   Date.yesterday.beginning_of_day,
                                                   Date.yesterday.end_of_day) }

  scope :client_campaigns, -> { where.not(user_id: User.admins.ids) }

  scope :updated_status_by_optimizations_campaigns, -> { where(updated_status_by: User::USER_BIDOPTIMIZATION) }

  scope :published_campaigns, -> { where(is_draft: false) }

  scope :by_pricing_model, -> (pricing_model) { where(pricing_model: pricing_model) }

  scope :by_name, -> (name) { where("#{self.table_name}.name LIKE ?", "%#{name}%") }

  scope :by_country, -> (country) { where(country_id: country) }

  scope :by_user, -> (user) { where(user_id: user) }

  scope :by_category, -> (category) { where(category_id: category) }

  scope :order_campaigns, ->  (sort_by, sort_dir) do
                                sort_campaigns_by = (sort_by if sort_by != "user_name") || "#{User.table_name}.name"
                                order("#{sort_campaigns_by} #{sort_dir}")
                              end

  # after_initialize :default_data

  after_initialize :sum_daily

  before_create :set_default_value

  before_update :update_user_budget, if: Proc.new { |p| !p.user.is_admin? }

  before_save :fix_start_time_and_end_time, if: Proc.new { |c| !c.is_draft }

  before_update :fix_start_time_and_end_time

  after_find :update_status, if: Proc.new { |obj| obj.has_attribute?(:timezone_id) }

  before_save :set_target

  before_update :check_target

  after_save :sync_mongodb

  %w(views clicks).each do |type|
    define_method "discrepancy_#{type}" do
      - (discrepancy_dsp_minus_tracking(type).to_f * 100) / eval("dsp_#{type}")
    end

    define_method "real_#{type}" do
      campaign_dsp_infos.present? ? campaign_dsp_infos.sum("daily_tracking_#{type}").round : daily_tracking_records.sum(type.to_sym)
    end

  end

  def discrepancy_dsp_minus_tracking(type)
    eval("dsp_#{type}") - eval("real_#{type}")
  end

  def ctr
    if views.present? and views >0
      (clicks.to_f / views.to_f) * 100
    else
      0
    end
  end

  def target_impression
    CPM? ? target : 0
  end

  def target_click
    CPC? ? target : 0
  end

  def daily_target_impression
    if CPM?
      _target = self.target.to_f
      number_of_day = (end_time.to_date - start_time.to_date + 1).to_i.to_f
      (_target / number_of_day).to_i
    else
      0
    end
  end

  def daily_target_click
    if CPC?
      _target = self.target.to_f
      number_of_day = (end_time.to_date - start_time.to_date + 1).to_i.to_f
      (_target / number_of_day).to_i
    else
      0
    end
  end

  def budget_spent
    if has_attribute?(:budget_spent_cents)
      Money.new(budget_spent_cents)
    else
      Money.new((CPM? and !views.blank?) ? (self.price_in_usd * views / 1000) : self.price_in_usd * clicks)
    end
  end

  def price_in_usd
    price.to_money(:USD).cents
  end
  # endregion

  def has_tracking_data
    daily_tracking_records.sum(:views) > 0
  end

  def reset
    self.name = Setting['campaign.name']
    self.ad_domain = Setting['campaign.ad_domain']
    self.start_time = Date.today
    self.end_time = Date.today

    category = Category.first
    if category.present?
      self.category_id = category.id
    end

    country = Country.first
    if country.present?
      self.country_id = country.id
    end

    timezone = Timezone.first
    if timezone.present?
      self.timezone_id = timezone.id
    end

    banner_type = BannerType.first
    if banner_type.present?
      self.banner_type_id = banner_type.id
    end

    self.pricing_model = :CPM
    self.status = :pending
    self.target = 1
    cost = Cost.where({country_id: country_id, pricing_model: pricing_model}).first
    if cost.present?
      self.price = cost.price
    end

    self.budget = self.class.get_budget({pricing_model: pricing_model, target: target, price: target}, self.budget_currency)
    self.age_ranges = []
    self.interests = []
    self.genders = []
    self.operating_systems = []
    self.categories = []
    self.banners.each do |b|
      b.really_destroy!
    end
    self.campaign_locations.each do |l|
      l.really_destroy!
    end
    self
  end

  # endregion


  # region Bidstalk

  #
  # create campaign on specific platform
  # @return [Array<string>] error messages
  # @todo not handler errors yet
  #
  def launch_on(platform)
    self.is_draft = false
    remove_locations
    if valid?
      if target_city
        create_whitelist
        clone_lat_long_from_city_into_campaign_location
      end
      Order.new({campaign: self, platform: platform})
      campaign_info = self.order.launch_campaign
      if campaign_info.present?
        self.save
        update_banner_dsp_id(campaign_info[:creatives])
        CampaignNotifier.delay.launch(self.id)
      end
    end
    errors.messages
  end

  def create_whitelist
    device_ids_csv = WhitelistService.generate_csv(self)
    if device_ids_csv.present?
      whitelisting = whitelistings.find_or_initialize_by(whitelist_type: Whitelisting::whitelist_types[:device_platform_id])
      whitelisting.whitelist = device_ids_csv
      whitelisting.save
    end
  end

  def clone_lat_long_from_city_into_campaign_location
    campaign_locations.destroy_all
    cities.each do |city|
      params = { name: city.name, latitude: city.latitude, longitude: city.longitude, radius: cities_radius*1000 }
      campaign_locations.create(params)
    end
  end

  #
  # update campaign on specific platform
  # @return [Array<string>] error messages
  # @todo not handler errors yet & only support bidstalk
  #
  def edit_on(platform)
    remove_locations
    if valid? && platform.id == Platform.bidstalk.id
      if target_city
        create_whitelist
        clone_lat_long_from_city_into_campaign_location
      end
      campaign_info = self.order.edit_campaign
      if campaign_info.present?
        update_banner_dsp_id(campaign_info[:creatives])
        # CampaignNotifier.delay.edit_on(self.id, self.previous_changes)
      end
    end
    errors.messages
  end

  def update_banner_dsp_id(creatives)
    creatives.each do |creative|
      banner_id = creative[:name].split('_').first
      banner = banners.find_by(id: banner_id)
      banner.update(dsp_creative_id: creative[:id]) if banner.present?
    end
  end

  def delete_on(platform)
    if valid? && platform.id == Platform.bidstalk.id
      respond = self.order.terminate_campaign
      if respond.present? && respond[:status] == 'success'
        Thread.new do
          CampaignNotifier.delete_on(self).deliver
        end
        self.destroy
      end
    end
    errors.messages
  end

  #
  # resume campaign on specific platform
  # @return [boolean] true if resume success
  #
  # def resume
  #
  #   return false unless self.status.to_sym == :paused
  #   order.resume_campaign
  #   if errors.none?
  #     update(status: :live, updated_status_at: Time.now)
  #     true
  #   else
  #     notify_error_updating_async
  #     false
  #   end
  # end

  def total_budget_as_money
    Money.new(budget_cents)
  end


  # Note that this function is different from budget_spent function above
  # thhoang FIXME should be revised later on
  def get_campaign_budget_spent
    hash_values = Hash[Campaign.joins(:daily_tracking_records)
                       .select("SUM( CASE WHEN pricing_model = 2 THEN #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.clicks ELSE #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.views/1000 END ) as budget_spent, #{DailyTrackingRecord.table_name}.campaign_id")
                       .where(DailyTrackingRecord.table_name.to_sym => {campaign_id: self.id})
                       .group("#{DailyTrackingRecord.table_name}.campaign_id")
                       .map { |m| [m.campaign_id, m[:budget_spent].to_f.round(2)/100] }]
    unless hash_values.values[0].nil?
      hash_values.values[0]
    else
      0.00
    end
  end

  def get_remaining_budget
    self.budget_cents.to_f - self.get_campaign_budget_spent*100 # to cents
  end


  def get_remaining_impression
    if CPM?
      if get_remaining_budget > 0
        return (get_remaining_budget*1000/self.price_cents).to_i
      end
    end
    0
  end


  def get_remaining_click
    if CPC?
      if get_remaining_budget > 0
        return (get_remaining_budget/self.price_cents).to_i
      end
    end
    0
  end

  def budget_withthout_cents
    budget_cents/100
  end

  def budget_was_withthout_cents
    budget_cents_was/100
  end

  def update_user_budget
    user = self.user
    amount = 0.0

    if is_action_create?
      amount = budget_withthout_cents
    elsif is_action_edit?
      amount = budget_withthout_cents - budget_was_withthout_cents
    end
    user.budget = user.budget - amount
    if user.changed?
      user.save
      create_activity ActivityType::CHARGE_ACCOUNT, parameters: { amount: amount }, owner: user
    end
  end

  def check_target
    target = calculate_target
    self.target = target if self.target != target
  end

  def set_target
    self.target = calculate_target
  end

  def calculate_target
    if self.pricing_model == 'CPC'
      target = self.budget.to_f / (self.price.to_f)
    else
      target = self.budget.to_f * 1000 / (self.price.to_f)
    end
    target.round
  end

  def is_start_time_in_future?
    self.start_time.to_date >= Date.today
  end

  # endregion

  # region Class Methods

  class << self

    def get_user_campaign(user, params)
      campaigns = launched(user).includes(:user)
      campaigns = campaigns.by_name(params[:name]) if params[:name].present?
      campaigns = campaigns.by_pricing_model(params[:type]) if params[:type].present?
      campaigns = campaigns.by_country(params[:country]) if params[:country].present?
      campaigns = campaigns.by_user(params[:user]) if params[:user].present?
      campaigns = campaigns.by_category(params[:category]) if params[:category].present?
      campaigns = campaigns.order_campaigns(params[:sort_by], params[:sort_dir]) if params[:sort_by].present?
      campaigns
    end

    def get_budget(params, currency = nil)
      # in Create mode, budget is set to default of $50.00
      unless params[:id].nil?
        self.find(params[:id]).budget.to_f
      else
        # thhoang FIXME should move this default value to Settings later on
        50.00
      end
    end

    def get_target(params, currency = nil)
      pricing_model = params[:pricing_model]
      budget = params[:budget].to_f
      price = currency.nil? ? params[:price].to_money(self.find(params[:id]).price.currency) : params[:price].to_money(currency)
      if pricing_model == 'CPC'
        budget / (price.to_f)
      else
        budget * 1000 / (price.to_f)
      end
    end

    # region query

    #
    # Query statistics for all campaign used to display on dashboard
    # @param [Array<date] period Start & end date of Daily tracking record
    # @return [Campaign::ActiveRecord_Relation] query result
    #
    def total_statistics(period)
      joins(:daily_tracking_records)
          .select("IFNULL(SUM(clicks),0) AS clicks, IFNULL(SUM(views),0) AS views, SUM( CASE WHEN pricing_model = 2 THEN #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.clicks ELSE #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.views/1000 END ) as budget_spent_cents")
          .where(DailyTrackingRecord.table_name.to_sym => {date: period[0].to_formatted_s(:db)..period[1].to_formatted_s(:db)}).first
    end

    def statistics(period)
      joins("LEFT JOIN (SELECT SUM(views) AS views, SUM(clicks) AS clicks,campaign_id from #{DailyTrackingRecord.table_name} WHERE (`#{DailyTrackingRecord.table_name}`.`date` BETWEEN '#{period[0].to_formatted_s(:db)}' AND '#{period[1].to_formatted_s(:db)}') GROUP BY campaign_id ) AS s on #{Campaign.table_name}.id = s.campaign_id")
          .select("#{Campaign.table_name}.*, IFNULL(s.views,0) AS views, IFNULL(s.clicks, 0) AS clicks")
          .where.not("(start_time > ? ) OR (end_time < ?)", period[1], period[0])
    end

    def order_with_default(order_field, sort_type)
      order_fields = ['start_time DESC', :name, :id]
      order_fields.prepend "#{order_field} #{sort_type}" if order_field.present?
      order(order_fields)
    end

    def search(field, term)
      if term.present?
        where("#{field} LIKE '%#{term}%'")
      else
        all
      end
    end

    def search_name(term)
      search(:name, term)
    end

    def belong_to_user(user)
      if user.present?
        where(is_draft: false, user_id: user.id)
      else
        where(is_draft: false)
      end
    end
    # endregion
  end

  def over_delivery?
    health_percent >= 0
  end

  def yesterday_under_delivery?
    health_percent(yesterday = true) <= -5
  end

  def force_pause_yesterday?
    paused? && updated_status_at.to_date <= 1.day.ago
  end

  def paused_by_optimization?
    paused? && updated_status_by == User::USER_BIDOPTIMIZATION
  end

  def repare_tracking_data
    without_optimization_enabled do
      start_time.to_date.upto([end_time.to_date, Date.today].min).each do |date|
        extractor = Extractor.new(date, self)
        extractor.run
        adjustment_campaign = CampaignDataAdjustment.new(date, self)
        adjustment_campaign.adjust_model_data
      end
    end
  end

  def disable_optimization
    update(allow_bid_optimization: false)
  end

  def enable_optimization
    update(allow_bid_optimization: true)
  end

  def update_dsp_views_clicks(dsp_report)
    update(dsp_views: dsp_report[:impressions].to_i, dsp_clicks: dsp_report[:clicks].to_i)
  end

  def current_status!
    now = DateTime.now.in_time_zone(timezone.zone)
    if self.terminated_at
      :terminated
    elsif is_draft || now < start_time
      :pending
    elsif now > end_time
      :completed
    elsif paused?
      :paused
    else
      :live
    end
  end

  # endregion

  # region Private Methods

  private

  def without_optimization_enabled
    enabled = self.allow_bid_optimization
    update_column(:allow_bid_optimization, false)
    yield
    update_column(:allow_bid_optimization, enabled)
  end

  def default_data
    return unless new_record?
    self.reset
  end

  def is_action_create?
    is_draft_was && is_draft_changed?
  end

  def is_action_edit?
    !is_draft && budget_cents_changed?
  end

  def reset_price
    return if is_total_statistics?
    cost = Cost.where({country_id: country_id, pricing_model: pricing_model}).first
    self.price = cost.price if cost.present?
  end

  # def notify_error_updating_async
  #   Thread.new do
  #     CampaignNotifier.error_updating(self).deliver
  #   end
  # end

  # def notify_pause_async
  #   Thread.new do
  #
  #   end
  # end

  def update_status
    update status: current_status! unless (id.present? && status.to_sym == current_status!)
  end

  def is_total_statistics?
    self.id.blank? && !self.new_record?
  end

  # endregion

  def user_budget
    if is_action_create?
      errors.add(:budget, I18n.t("campaigns.over_budget")) if budget_withthout_cents > user.budget.to_f
    elsif is_action_edit?
      if budget_cents_changed?
        changed = budget_withthout_cents - budget_was_withthout_cents
        errors.add(:budget, I18n.t("campaigns.update.error.messages.budget")) if changed > user.budget.to_f
      end
    end
    errors.add(:budget, I18n.t("campaigns.minimum_budget")) if budget_withthout_cents < 50
  end

  def fix_start_time_and_end_time
    self.start_time = start_time.beginning_of_day
    self.end_time = end_time.end_of_day
    self.terminated_at = terminated_at.end_of_day if self.terminated_at
  end

  def remove_locations
    locations = CampaignLocation.only_deleted.where(campaign_id: self.id)
    locations.each do |l|
      tracking_data = LocationTrackingRecord.find_by(campaign_location_id: l.id)
      l.really_destroy! if tracking_data.nil?
    end
  end

  def sync_mongodb
    MongoDb::Campaign.sync(self) unless is_draft
  end

  def set_default_value
    self.status = :pending
  end

  def not_draft_and_not_target_city?
    !is_draft && !target_city
  end
end