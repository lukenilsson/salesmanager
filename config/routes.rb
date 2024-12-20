Rails.application.routes.draw do
  root "dashboard#index"
  get 'dashboard', to: 'dashboard#index'

  # Define routes for Accounts
  resources :accounts, only: [:index, :show, :edit, :update]


  resources :reports, only: [:new, :index, :create]

  get "up" => "rails/health#show", as: :rails_health_check
end
