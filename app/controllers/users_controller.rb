class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.load_users(params).page(params[:page]).per(params[:per])
    respond_to do |format|
      format.html
      format.json { render json: @users, each_serializer: UserSerializer }
    end
  end

  def show
    if @user.approved && can?(:manage, @user) && @user.id != current_user.id
      flash[:notice] = 'User has been approved'
    end
    respond_to do |format|
      format.html
      format.json { render json: @user, serializer: UserSerializer }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.json { render json: @user, serializer: UserSerializer }
    end
  end

  def new
    
  end

  def create
    @user = User.new(new_user_params)
    @user.approved = true
    @user.updated_status_at = @user.confirmed_at = Time.now
    if @user.save
      @user.set_user_roles(params[:user][:role])
      render json: @user, serializer: UserSerializer
    else
      render json: {message: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @user.update(new_user_params)
        format.json { render json: @user, serializer: UserSerializer }
      else
        format.json { render json: { message: @user.errors.full_messages}, status: :unprocessable_entity }
      end
    end
  end

  def approve
    respond_to do |format|
      @user.assign_attributes(approved: params[:approved], updated_status_at: Time.now)
      if @user.save(validate: false) && @user.approved && !@user.confirmed?
        @user.send_on_create_confirmation_instructions(@user.approved)
      end
      format.json { render json: @user, serializer: UserSerializer }
    end
  end

  def total_user
    @users = User.load_users(params)
    respond_to do |format|
      format.json { render json: { totalSize: @users.size } }
    end
  end

  def approved
    @users = User.where(approved: true)
    respond_to do |format|
      format.json { render json: @users, each_serializer: UserSerializer }
    end
  end

  def add_budget
    user = User.find_by(email: params[:email])
    respond_to do |format|
      if user.approved
        user.budget = user.budget + params[:budget].to_f
        user.save(validate: false)
        format.json { render json: user, serializer: UserSerializer }
      else
        format.json { render json: { alert: 'Can not add budget to unapproved user' } }
      end
    end
  end

  def get_users
    @users = User.all

    render json: @users, each_serializer: UserSerializer
  end

  def reset_password
    generated_password = Devise.friendly_token.first(9)
    if @user.update(password: generated_password)
      render json: { generated_password: generated_password, status: 200 }
    else
      render json: {message: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private
  def new_user_params
    params[:user][:created_by_admin] = current_user.is_admin?
    params.require(:user).permit(:email, :name, :company, :password, :created_by_admin)
  end

  def user_params
    params.require(:user).permit(:name, :company)
  end
end
