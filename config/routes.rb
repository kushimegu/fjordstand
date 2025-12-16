Rails.application.routes.draw do
  resources :notifications, only: [:index] do
    get :read, on: :member
    get :read_all, on: :collection
  end
  resources :transactions, only: [:index] do
    resources :messages, only: %i[index create]
  end
  get "/drafts", to: "items#drafts"
  get "/entries", to: "entries#index"
  get "/listings", to: "items#listings"
  resources :items do
    resource :entries, only: %i[create destroy]
  end
  root to: "pages#home"
  resource :session, only: %i[create destroy]
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'logout', to: 'sessions#destroy', as: 'logout'
end
