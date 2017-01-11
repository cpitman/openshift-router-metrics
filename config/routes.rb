Rails.application.routes.draw do
  get '/', to: 'stats#index'
  get 'auth/:provider/callback', to: 'sessions#create'
  post 'logout', to: 'sessions#destroy'
end
