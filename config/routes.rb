Rails.application.routes.draw do
  devise_for :users
  root to: 'attachments#index'

  resources :attachments, only: [:new, :create]

  mount Base => '/'
end
