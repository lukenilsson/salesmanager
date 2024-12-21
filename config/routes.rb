Rails.application.routes.draw do
  root "dashboard#index"
  get 'dashboard', to: 'dashboard#index'

  # Define routes for Accounts
  resources :accounts, only: [:index, :show, :edit, :update] do
    # Nested route for products sold by a specific account
    get 'products', on: :member
  end

  # Define routes for Products
  resources :products, only: [:show]

  # Define routes for Reports
  resources :reports, only: [:new, :index, :create]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
