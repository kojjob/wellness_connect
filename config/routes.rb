Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"

  # Test route for debugging
  get "test/dropdown_debug", to: "test#dropdown_debug" if Rails.env.development?

  # Admin dashboard (admin-only access)
  namespace :admin do
    root to: "dashboard#index" # /admin
  end

  # Provider dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Provider namespace for provider-specific features
  namespace :provider do
    get "analytics", to: "analytics#index", as: :analytics
  end

  # Public provider browsing
  get "providers", to: "provider_profiles#index", as: :providers

  # Static pages
  get "become-a-provider", to: "pages#become_provider", as: :become_provider
  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact

  resources :provider_profiles do
    resources :services
    resources :availabilities
    resources :reviews, only: [ :new, :create, :edit, :update, :destroy ]
  end

  # Appointments
  resources :appointments, only: [ :index, :show, :new, :create ] do
    member do
      patch :cancel
    end
  end

  # Notifications
  resources :notifications, only: [ :index, :destroy ] do
    member do
      post :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end

  # Notification Preferences (singular resource - one per user)
  resource :notification_preferences, only: [ :edit, :update ]

  # Payments
  resources :payments, only: [ :index, :create ] do
    member do
      patch :confirm
    end
  end

  # Conversations and Messages (messaging system)
  resources :conversations, only: [ :index, :show, :create ] do
    member do
      patch :archive
      patch :unarchive
    end

    # Nested messages within conversations
    resources :messages, only: [ :create, :edit, :update, :destroy ] do
      member do
        patch :mark_as_read
        get :download_attachment
      end
    end
  end

  # Stripe webhooks
  post "stripe/webhooks", to: "stripe_webhooks#create", as: :stripe_webhooks

  # Admin namespace - full admin resources
  namespace :admin do
    resources :users do
      member do
        post :suspend
        post :unsuspend
        post :block
        post :unblock
        delete :remove_avatar
      end
    end
    resources :provider_profiles, except: [ :destroy ] # View and edit provider profiles (no deletion for data integrity)
    resources :patient_profiles, except: [ :destroy, :new, :create ] # View and edit patient profiles (no creation/deletion for data integrity)
    resources :appointments, only: [ :index, :show ]
    resources :payments, only: [ :index, :show ]
    resources :announcements, only: [ :new, :create ] do
      collection do
        get :preview
      end
    end
  end

  # Error pages (handled by ErrorsController with CSP nonces)
  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Test routes for flash message system (test environment only)
  if Rails.env.test?
    get "test_flash/success", to: "test_flash#success"
    get "test_flash/error", to: "test_flash#error"
    get "test_flash/warning", to: "test_flash#warning"
    get "test_flash/info", to: "test_flash#info"
    get "test_flash/notice", to: "test_flash#notice"
    get "test_flash/multiple", to: "test_flash#multiple"
    get "test_flash/turbo_stream_flash", to: "test_flash#turbo_stream_flash"
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Test-only routes for flash message system testing
  if Rails.env.test?
    get "test_flash/success", to: "test_flash#success"
    get "test_flash/error", to: "test_flash#error"
    get "test_flash/warning", to: "test_flash#warning"
    get "test_flash/info", to: "test_flash#info"
    get "test_flash/notice", to: "test_flash#notice"
    get "test_flash/multiple", to: "test_flash#multiple"
    get "test_flash/turbo_stream_flash", to: "test_flash#turbo_stream_flash"
  end
end
