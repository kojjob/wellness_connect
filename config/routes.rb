Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"

  # Provider dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Public provider browsing
  get "providers", to: "provider_profiles#index", as: :providers

  # Static pages
  get "become-a-provider", to: "pages#become_provider", as: :become_provider
  get "about", to: "pages#about", as: :about

  resources :provider_profiles do
    resources :services
    resources :availabilities
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
