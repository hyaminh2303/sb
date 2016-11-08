class CampaignNotifier < ApplicationMailer
  def launch(campaign_id)
    campaign = Campaign.find(campaign_id)
    set_vars campaign
    campaign.errors.none? ? mail_success(I18n.t('campaigns.notifier.email.subject.create_success')) : mail_error(I18n.t('campaigns.notifier.email.subject.error'))
  end

  def edit_on(campaign_id, previous_changes)
    @previous_changes = previous_changes
    campaign = Campaign.find(campaign_id)
    @edit = true
    set_vars campaign
    campaign.errors.none? ? mail_success(I18n.t('campaigns.notifier.email.subject.edit_success')) : mail_error(I18n.t('campaigns.notifier.email.subject.error'))
  end

  def terminated_on(campaign_model)
    set_vars campaign_model    
    mail(to: [ENV['YOOSE_ADMIN_EMAIL']], subject: mail_subject(I18n.t('campaigns.notifier.email.subject.terminated')))
  end

  def pause(campaign_model)
    set_vars campaign_model
    mail to: ENV['YOOSE_ADMIN_EMAIL'], subject: mail_subject(I18n.t('campaigns.notifier.email.subject.pause'))
  end

  def error_updating(campaign_id, messages)
    campaign = Campaign.find(campaign_id)
    set_vars campaign
    @messages = messages || []
    mail(to: ENV['YOOSE_ADMIN_EMAIL'], subject: mail_subject(I18n.t('campaigns.notifier.email.subject.error_updating')), template_name: 'error_updating')
  end

  def pause_failed(campaign_id, user_id)
    @campaign = Campaign.find(campaign_id)
    @user = User.find_by_id(user_id)
    @username = @user.nil? ? User::USER_BIDOPTIMIZATION : @user.name
    @error = BidstalkTask.find_by(campaign_id: campaign_id).message rescue nil
    mail(subject: mail_subject('[Action required] Pause Campaign'))
  end

  def resume_failed(campaign_id, user_id)
    @campaign = Campaign.find(campaign_id)
    @user = User.find_by_id(user_id)
    @username = @user.nil? ? User::USER_BIDOPTIMIZATION : @user.name
    @error = BidstalkTask.find_by(campaign_id: campaign_id).message rescue nil

    mail(subject: mail_subject('[Action required] Resume Campaign'))
  end

  def terminate_failed(campaign_id, user_id)
    @campaign = Campaign.find campaign_id
    @user = User.find_by_id(user_id)
    @username = @user.nil? ? User::USER_BIDOPTIMIZATION : @user.name
    @error = BidstalkTask.find_by(campaign_id: campaign_id).message rescue nil
    mail(subject: mail_subject('[Action required] Terminate Campaign'))
  end

  private

  def set_vars(campaign_model)
    @user = campaign_model.user
    @campaign = campaign_model
    @butget = get_unit_budget(campaign_model)
    @messages = campaign_model.errors.full_messages unless campaign_model.errors.none?
  end

  def mail_success(subject)
    mail(to: [ENV['YOOSE_ADMIN_EMAIL']], subject: mail_subject(subject), template_name: 'success')
  end

  def mail_error(subject)
    mail(to: ENV['YOOSE_ADMIN_EMAIL'], subject: mail_subject(subject), template_name: 'error')
  end

  def user_email
    "#{@user.name} <#{@user.email}>"
  end
end
