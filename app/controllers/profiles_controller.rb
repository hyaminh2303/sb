class ProfilesController < ApplicationController
  before_action :set_user, :valid_user

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(update_params)
        format.html { redirect_to root_url, notice: t('users.update.success')}
      else
        format.html { render :edit, alert: @user.errors.full_messages.join(', ')}
      end
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def update_params
    params.require(:user).permit(:name, :company)
  end

  def valid_user
    redirect_to(root_url, alert: 'You are not authorized to access this page.') if params[:id].to_i != current_user.id
  end
end
