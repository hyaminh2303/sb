require 'sidekiq/web'

Rails.application.routes.draw do
  resources :platform_supports, only: [:index, :new] do
    collection do
      get :edit
      post :save, to: 'platform_supports#save_platform_support'
    end
  end

  resources :profiles, only: [:show, :edit, :update]

  # constraint = lambda { |request|
  #   request.env["warden"].authenticate? and
  #   (request.env['warden'].user.admin? or request.env['warden'].user.monitor?)
  # }

  resources :bidstalk_tasks, only: [:index]

  authenticate :user do
    mount Sidekiq::Web => '/monitoring'
  end

  get 'campaign_device_stats/index'

  get 'campaign_details_controller/detail'

  get 'campaign_details_controller/index'

  get 'campaign_location_stats/index'

  get 'campaign_app_stats/index'

  get 'campaign_carrier_stats/index'

  get 'campaign_location_stats/index'

  get 'campaign_creative_stats/index'

  get 'campaigns_os_stats/index'

  get 'campaign_reports/exprt_as_agency'

  get 'campaign_reports/export'

  get 'campaign_reports/export_as_agency'

  get 'campaign_reports/export_device_id'

  get 'campaigns/index'
  get 'campaigns/new'
  get 'campaigns/:id/edit', to: 'campaigns#edit'
  get 'campaigns/:id/clone', to: 'campaigns#clone'
  get 'types', to: 'api/types#index'
  get 'users_list', to: 'users#get_users'
  get 'campaigns/steps'
  get 'campaigns/step1'
  get 'campaigns/step2'
  get 'campaigns/step3'
  get 'campaigns/step4'
  get 'campaigns/data_tracking', to: 'data_tracking#tracking'

  resources :campaigns do
    resources :activities, only: [:index]
    resources :data_tracking, only: [:index]
  end

  root 'home#index'

  resources :roles, only: [:index]

  resources :campaign_details, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_details#index', as: 'index'
    end
  end

  resources :campaign_reports, only: [] do
    member do
      get 'export'
      get 'export_as_agency'
      get 'export_device_id'
    end
  end

  resources :campaign_os_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_os_stats#index', as: 'index'
    end
  end

  resources :campaign_creative_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_creative_stats#index', as: 'index'
    end
  end

  resources :campaign_exchange_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_exchange_stats#index', as: 'index'
    end
  end

  resources :campaign_carrier_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_carrier_stats#index', as: 'index'
    end
  end

  resources :campaign_location_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_location_stats#index', as: 'index'
    end
  end

  resources :campaign_app_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_app_stats#index', as: 'index'
    end
  end

  resources :campaign_device_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_device_stats#index', as: 'index'
    end
  end

  resources :campaign_city_stats, only: [] do
    collection do
      get ':campaign_id', to: 'campaign_city_stats#index', as: 'index'
    end
  end

  namespace :api, :defaults => {:format => :json} do

    resources :banners do
      collection do
        post 'upload' => 'banners#upload'
      end
    end

    resources :campaigns do
      collection do
        get 'get_current_step',   to: 'campaigns#get_current_step'
        post 'save_current_step', to: 'campaigns#save_current_step'
        post 'cancel',            to: 'campaigns#cancel'
        post 'launch',            to: 'campaigns#launch'
        get 'past',               to: 'campaigns#past_campaigns'
      end
      member do
        get 'get_budget', to: 'campaigns#get_budget'
        get 'get_target', to: 'campaigns#get_target'
        put 'launch'
        post 'edit',      to: 'campaigns#edit'
        post 'pause',     to: 'campaigns#pause'
        post 'resume',    to: 'campaigns#resume'
        post 'repare_tracking_data', to: 'campaigns#repare_tracking_data'
        post 'deleteCampaign', to: 'campaigns#delete_campaign'
        put 'cancel'
        delete 'remove_campaign_locations', to: 'campaigns#remove_campaign_locations'
      end
    end
    resources :campaign_locations

    resources :cities, only: [:index]
    resources :companies, only: [:index]
    resources :countries
    
    resources :categories do
      collection do
        get :grouped
        get :parents
      end
    end
    resources :timezones
    resources :costs do
     collection do
        get 'get_price', to: 'costs#get_price'
      end
    end

    resources :age_ranges
    resources :interests
    resources :operating_systems
    resources :genders

    resources :stats do
      collection do
        get 'campaigns', to: 'stats#campaigns'
        get 'total_campaigns', to: 'stats#total_campaigns'
        get 'views', to: 'stats#views'
        get 'clicks', to: 'stats#clicks'
        get 'budget_spent', to: 'stats#budget_spent'
      end
    end
  end

  get 'maintenance' => 'maintenance#index'
  get 'maintenance/jobs' => 'maintenance#jobs'
  get 'maintenance/get_schedule_frequency' => 'maintenance#get_schedule_frequency', format: :json
  get 'maintenance/running_jobs' => 'maintenance#running_jobs', format: :json
  post 'maintenance/save_schedule_frequency' => 'maintenance#save_schedule_frequency', format: :json
  post 'maintenance/run_daily_tracking_worker' => 'maintenance#run_daily_tracking_worker', format: :json
  get 'update_exchange' => 'api/ad_exchanges#update_exchanges'
  
  devise_for :users,
             path: '',
             path_names: {
                 sign_in: 'login',
                 sign_out: 'logout',
                 password: 'secret',
                 confirmation: 'verification',
                 unlock: 'unblock',
                 registration: '',
                 sign_up: 'register'},
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations',
                 passwords: 'users/passwords'
             }
  resources :users do
    member do
      post :approve
      post :reset_password
    end
    collection do
      post :add_budget
      get :approved
      get :total_user
    end
  end
end
