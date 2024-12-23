Rails.application.routes.draw do
  root "dashboard#index"
  get 'dashboard', to: 'dashboard#index'

  # Define routes for Accounts
  resources :accounts, only: [:index, :show, :edit, :update] do
    # Nested route for products sold by a specific account
    get 'products', on: :member
    # Custom route for exporting sales to CSV
    get 'export_sales', on: :member

    # Nested Sales Routes
    resources :sales, only: [:edit, :update, :destroy]
  end

  # Define routes for Products
  resources :products, only: [:show] do
    # Custom route for exporting sales to CSV
    get 'export_sales', on: :member
  end

  # Define routes for Reports
  resources :reports, only: [:new, :index, :create]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
