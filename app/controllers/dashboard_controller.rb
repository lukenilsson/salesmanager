class DashboardController < ApplicationController
  def index
    # Filter parameters
    year = params[:year]
    month = params[:month]
    account_id = params[:account_id]
    product_id = params[:product_id]
    quantity_threshold = params[:quantity_threshold]

    @sales = Sale.includes(:account, :product).all

    @sales = @sales.where(year: year) if year.present?
    @sales = @sales.where(month: month) if month.present?
    @sales = @sales.where(account_id: account_id) if account_id.present?
    @sales = @sales.where(product_id: product_id) if product_id.present?
    @sales = @sales.where("quantity >= ?", quantity_threshold) if quantity_threshold.present?

    # Data for charts or summary (e.g. total quantity sold, top products, etc.)
    @total_quantity = @sales.sum(:quantity)
    @top_accounts = Sale.joins(:account)
    .group("accounts.name")
    .sum(:quantity)
    @top_products = @sales.group("products.name").sum(:quantity).sort_by{|_,qty| -qty}.first(10)
  end
end
