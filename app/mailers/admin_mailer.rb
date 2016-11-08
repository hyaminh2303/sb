class AdminMailer < ApplicationMailer
  def new_user_waiting_for_approval(user, time)
    @time = time
    @user = user
    mail(to: ENV['YOOSE_ADMIN_EMAIL'], subject: mail_subject('New User Registration'))
  end

  def notify_error(ex)
    mail(to: ENV['YOOSE_ADMIN_EMAIL'], subject: mail_subject('System Error'), body: ex.message + "\n" + ex.backtrace.to_s)
  end
end
