class CampaignService
  MIN_BUDGET = 50

  def self.update(_campaign, user, params)
    campaign = CampaignActivityTracking.new(CampaignMailLogger.new(_campaign, user), user)
    if campaign.update(params)
      campaign.publish(:update) unless campaign.is_draft
      true
    else
      campaign.publish(:update_failed) unless campaign.is_draft
      false
    end
  end

  def self.pause(_campaign, user = nil)
    campaign = CampaignActivityTracking.new(CampaignMailLogger.new(_campaign, user), user)
    username = user.nil? ? User::USER_BIDOPTIMIZATION : user.name

    BidstalkTask.where(campaign_id: campaign.id).delete_all
    BidstalkTask::ResumeCampaign.where(campaign_id: campaign.id).delete_all
    task = BidstalkTask::PauseCampaign.find_or_create_by!(campaign_id: campaign.id)
    task.update(done: false)

    if task.execute
      campaign.publish(:pause_manually) unless username == User::USER_BIDOPTIMIZATION
    else
      campaign.publish(:pause_failed)
    end

    campaign.update(status: :paused, updated_status_at: Time.zone.now, updated_status_by: username)
  end

  def self.resume(_campaign, user = nil)
    campaign = CampaignActivityTracking.new(CampaignMailLogger.new(_campaign, user), user)
    return unless campaign.status.to_sym == :paused
    username = user.nil? ? User::USER_BIDOPTIMIZATION : user.name

    BidstalkTask.where(campaign_id: campaign.id).delete_all
    task = BidstalkTask::ResumeCampaign.find_or_create_by!(campaign_id: campaign.id)
    task.update(done: false)

    if task.execute
      campaign.publish(:resume_manually)
    else
      campaign.publish(:resume_failed)
    end

    campaign.update(status: :live, updated_status_at: Time.zone.now, updated_status_by: username)
  end

  def self.terminate(_campaign, user)
    campaign = CampaignActivityTracking.new(CampaignMailLogger.new(_campaign, user), user)
    BidstalkTask.where(campaign_id: campaign.id).delete_all
    task = BidstalkTask::TerminateCampaign.find_or_create_by!(campaign_id: campaign.id)
    task.update(done: false)

    if task.execute
      campaign.publish(:terminate)
    else
      campaign.publish(:terminate_failed)
    end

    campaign.update_attributes(terminated_at: Time.zone.now, status: :terminated, updated_status_at: Time.zone.now)
  end

  # region for clone campaign
  def self.clone(current_campaign, target_campaign, current_user)
    destroy_data_current_campaign(current_campaign)
    clone_new_campaign(target_campaign, current_user)
  end

  def self.destroy_data_current_campaign(current_campaign)
    current_campaign.banners.each do |b|
      b.really_destroy!
    end
    current_campaign.campaign_locations.each do |l|
      l.really_destroy!
    end
    current_campaign.operating_systems.destroy_all
    current_campaign.destroy
  end

  def self.clone_new_campaign(target_campaign, current_user)
    campaign            = target_campaign.dup
    campaign.is_draft   = true
    campaign.name       += "_copied"
    campaign.user       = current_user
    campaign.start_time = Time.now if campaign.start_time < Time.now
    campaign.end_time   = Time.now if campaign.end_time < Time.now
    campaign.cities     = target_campaign.cities
    campaign.categories = target_campaign.categories
    campaign.genders = target_campaign.genders
    campaign.dsp_views = 0
    campaign.dsp_clicks = 0
    campaign.terminated_at = nil

    if !current_user.is_admin? && campaign.current_status! != 'completed'
      campaign.budget = MIN_BUDGET if campaign.budget < MIN_BUDGET
    end

    campaign.status = :pending

    cost = Cost.find_by(country_id: campaign.country_id, pricing_model: campaign.pricing_model)
    if cost.present?
      campaign.price = cost.price
    end

    campaign.set_target
    campaign.save

    clone_banners_from_campaign(target_campaign, campaign)

    clone_locations_from_campaign(target_campaign, campaign)

    # Clone OS info
    campaign.operating_systems = target_campaign.operating_systems

    campaign
  end

  def self.clone_banners_from_campaign(target_campaign, new_campaign)
    target_campaign.banners.each do |b|
      file = Tempfile.new ['', ".#{b.image_url.split('.').last}"]
      file.binmode
      file.write open(b.image_url).read
      file.rewind
      new_campaign.banners.create(name: b.name, landing_url: b.landing_url, image: file)
    end
  end

  def self.clone_locations_from_campaign(target_campaign, new_campaign)
    target_campaign.campaign_locations.each do |l|
      new_campaign.campaign_locations.create(
                                        name: l.name,
                                        latitude: l.latitude,
                                        longitude: l.longitude,
                                        radius: l.radius)
    end
  end
end
