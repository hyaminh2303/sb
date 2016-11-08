class ApplicationMailer < ActionMailer::Base
  include MailerHelper
  helper MailerHelper

  default from: "#{ENV['YOOSE_DEFAULT_SENDER_NAME']} <#{ENV['YOOSE_DEFAULT_SENDER_EMAIL']}>",
          to: ENV['YOOSE_ADMIN_EMAIL'],
          content_type: "text/html"

  protected

  def mail_subject(subject)
    "#{prefix_email} #{subject}"
  end

  def prefix_email
    t("prefix_email_#{Rails.env}")
  end
end