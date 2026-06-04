class AdminConstraint
  def matches?(request)
    user_id = request.session[:user_id]
    return false unless user_id

    user = User.find_by(id: user_id)
    user&.admin?
  end
end

Rails.application.routes.draw do
  resources :items do
    resource :entries, only: %i[create destroy]
    resources :comments, only: %i[create destroy]
    resource :watches, only: %i[create destroy]
  end
  scope module: :items do
    resources :listings, only: %i[index]
  end
  resources :entries, only: %i[index]
  resources :watches, only: %i[index]
  resources :transactions, only: [:index] do
    resources :messages, only: %i[index create destroy]
  end
  resources :notifications, only: [:index] do
    scope module: :notifications do
      resource :read, only: %i[update]
      collection do
        patch :read_all, to: "reads#update_all"
      end
    end
  end
  resource :session, only: %i[create destroy]
  get "auth/:provider/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"
  delete "logout", to: "sessions#destroy", as: "logout"
  get "/terms", to: "pages#terms"
  get "/privacy", to: "pages#privacy"
  root to: "pages#home"
  constraints AdminConstraint.new do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
