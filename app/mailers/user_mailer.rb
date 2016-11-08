class UserMailer < ApplicationMailer

  def platform_registration(user)
    @user = user
    mail(to: @user.email, subject: mail_subject('Platform Registration'))
  end
end
