class User < ActiveRecord::Base
  USER_BIDOPTIMIZATION = 'Bid Optimization'
  rolify
  has_and_belongs_to_many :roles, :join_table => :sb_users_roles
  # region Devise modules

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # endregion

  # region Scopes

  scope :ordered_by_name, -> { order(:name) }
  scope :load_all_user_except_admin, -> { where.not(id: User.with_role(:admin)) }
  scope :admins, -> { with_role :admin }

  # endregion

  # region Associations

  has_many :campaigns

  # endregion
  
  # region Validation
  
  validates :email, :encrypted_password, :reset_password_token, :current_sign_in_ip, :last_sign_in_ip, :name, length: {:maximum => 255}
  validates :name, presence: true
  validates :company, presence: true

  # endregion

  after_create :send_admin_mail, :send_user_mail, :add_default_role
  
  # region Instance Methods

  def   current_campaign
    campaigns.find_by(is_draft: true)
  end

  # endregion

  def active_for_authentication? 
    super && approved? 
  end 

  def inactive_message 
    if !approved? 
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end

  def send_admin_mail
    time = Time.zone.now
    AdminMailer.new_user_waiting_for_approval(self, time).deliver unless created_by_admin
  end

  def send_user_mail
    UserMailer.platform_registration(self).deliver unless created_by_admin
  end

  def send_on_create_confirmation_instructions(allow_send = false)
    if allow_send
      send_confirmation_instructions
    end
  end

  def is_admin?
    has_role? :admin
  end

  def set_user_roles(role_id)
    roles << Role.find_by_id(role_id).presence || Role.find_by_name('agency')
  end

  class << self
    def load_users(params)
      users = all
      if params[:sort_by] == 'status'
        users = users.order("approved #{params[:order_by]}").order("updated_status_at #{params[:order_by]}") if params[:order_by]
      else
        users = users.order("#{params[:sort_by]} #{params[:order_by]}") if params[:sort_by] && params[:order_by]
      end
      users = users.where("name LIKE ? OR email LIKE ?", "%#{params[:search_term]}%", "%#{params[:search_term]}%") if params[:search_term]
      users
    end
  end

  private

  def add_default_role
    add_role :agency if !created_by_admin
  end
end
