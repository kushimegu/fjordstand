Rails.application.routes.draw do
  resources :items
  root to: "pages#home"
  resource :session, only: %i[create destroy]
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'logout', to: 'sessions#destroy', as: 'logout'
end
