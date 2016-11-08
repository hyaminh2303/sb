class WorkerMailer < ApplicationMailer
  def pause_campaign(campaign, time)
    set_vars(campaign, time)
    mail(subject: "#{ prefix_email } #{ t('.subject', reached: @health_percent) }", body: t('.body', campaign: @campaign, time: @time, reached: @health_percent))
  end

  def resume_campaign(campaign, time)
    set_vars(campaign, time)
    mail(subject:  "#{ prefix_email } #{ t('.subject') }", body: t('.body', campaign: @campaign, time: @time))
  end

  def over_delivery(campaign)
    set_vars(campaign, Time.now)
    mail(subject: "#{ prefix_email } #{ t('.subject', reached: @health_percent) }", body: t('.body', campaign: @campaign, time: @time, reached: @health_percent))
  end

  def over_budget(campaign)
    set_vars(campaign, Time.now)
    mail(subject: "#{ prefix_email } #{ t('.subject', reached: @health_percent) }", body: t('.body', campaign: @campaign, time: @time, reached: @health_percent))
  end

  def increase_maxbid(campaign, time)
    set_vars(campaign, time)
    mail(subject:  "#{ prefix_email } #{ t('.subject') }", body: t('.body', campaign: @campaign, time: @time))
  end

  def refund_budget(campaign, time)
    set_vars(campaign, time)
    content = t('.body', campaign: @campaign, time: @time, remaining_budget: @remaining_budget, user: @user.name)
    mail(to: [ENV['YOOSE_ADMIN_EMAIL'], @user.email], subject:  "#{ prefix_email } #{ t('.subject') }", body: content)
  end

  def error_worker(action, time, error, campaign)
    mail(subject:  "#{ prefix_email } #{ t('.subject') }", body: t('.body', action: action, time: time, error: error, campaign: campaign.name))
  end

  private
  def set_vars(campaign, time)
    @time = time.strftime(t('send_email_time'))
    @campaign = campaign.name
    @remaining_budget = campaign.get_remaining_budget / 100 #to budget without cent 
    @user = campaign.user
    @health_percent = "#{campaign.health_percent} %"
  end
end
