Rails.application.routes.draw do
  # Administration
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)  

  # API
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'register', to: 'auth#register'
      post 'login', to: 'auth#login'
      delete 'logout', to: 'auth#logout'
      post 'password/reset', to: 'passwords#create'
      put 'password/update', to: 'passwords#update'
      
      # Confirmación de cuenta
      get 'confirm_account', to: 'auth#confirm_account'
      post 'resend_confirmation', to: 'auth#resend_confirmation'

      # Users
      resources :users, only: [:index, :show, :update, :destroy] do
        member do
          # Gestión de baneos
          post 'ban', to: 'users#ban'
          post 'unban', to: 'users#unban'
        end
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Swagger
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end
