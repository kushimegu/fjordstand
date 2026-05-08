Rails.application.routes.draw do
  resources :notifications, only: [:index] do
    scope module: :notifications do
      resource :read, only: %i[update]
      collection do
        patch :read_all, to: "reads#update_all"
      end
    end
  end
  resources :transactions, only: [:index] do
    resources :messages, only: %i[index create destroy]
  end
  get "/entries", to: "entries#index"
  scope module: :items do
    resources :listings, only: %i[index]
  end
  get "/watches", to: "watches#index"
  resources :items do
    resource :entries, only: %i[create destroy]
    resources :comments, only: %i[create destroy]
    resource :watches, only: %i[create destroy]
  end
  root to: "pages#home"
  get "/terms", to: "pages#terms"
  get "/privacy", to: "pages#privacy"
  resource :session, only: %i[create destroy]
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: 'sessions#failure'
  delete 'logout', to: 'sessions#destroy', as: 'logout'
  get 'up' => 'rails/health#show', as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
