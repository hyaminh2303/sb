class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  layout :layout_by_resource
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  def current_campaign
    current_campaign = current_user.current_campaign
    if current_campaign.blank?
      current_campaign = Campaign.new
      current_campaign.user = current_user
      current_campaign.save
    end
    current_campaign
  end

  rescue_from StandardError do |ex|
    AdminMailer.notify_error(ex).deliver
    Rails.logger.error(ex.message + (ex.backtrace.join("\n") rescue ''))
    render json: {}, status: :unprocessable_entity
  end unless Rails.env.development?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected
  def layout_by_resource
    if devise_controller? && action_name == "new"
      "auth"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :company]
  end
end
