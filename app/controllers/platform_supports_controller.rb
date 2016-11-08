class PlatformSupportsController < ApplicationController
  before_action :authorize_resource, except: [:index]
  before_action :set_platform_support, only: [:index, :edit, :new]
  def index
  end

  def save_platform_support
    Setting.platform_support = params[:content]
    redirect_to platform_supports_url
  end

  private
  def set_platform_support
    @platform_support = Setting.platform_support
  end
  
  def authorize_resource
    authorize! :manage, :platform_supports
  end
end

