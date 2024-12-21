class DashboardController < ApplicationController
  def index
    # Filter parameters
    year = params[:year]
    month = params[:month]
    account_id = params[:account_id]
    product_id = params[:product_id]
    quantity_threshold = params[:quantity_threshold]

    @sales = Sale.includes(:account, :product).all

    # Apply filters based on parameters
    @sales = @sales.where(year: year) if year.present?
    @sales = @sales.where(month: month) if month.present?
    @sales = @sales.where(account_id: account_id) if account_id.present?
    @sales = @sales.where(product_id: product_id) if product_id.present?
    @sales = @sales.where("quantity >= ?", quantity_threshold) if quantity_threshold.present?

    # Dashboard metrics
    @total_accounts = Account.count

    # Most popular product
    @most_popular_product = @sales.joins(:product)
                                   .group("products.name")
                                   .order("SUM(sales.quantity) DESC")
                                   .limit(1)
                                   .pluck("products.name, SUM(sales.quantity)")
                                   .first
    @most_popular_product_name = @most_popular_product ? @most_popular_product[0] : "No data available"

    # Total units sold
    @total_units_sold = @sales.sum(:quantity)

    # Additional data for charts or summary
    @top_accounts = @sales.joins(:account)
                          .group("accounts.name")
                          .sum(:quantity)
    @top_products = @sales.joins(:product)
                          .group("products.name")
                          .sum(:quantity)
                          .sort_by { |_, qty| -qty }
                          .first(10)
  end
end
