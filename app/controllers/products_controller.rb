class ProductsController < ApplicationController
  include Sortable

  before_action :set_product, only: [:show, :export_sales]
  before_action :permit_sorting_params, only: [:show, :export_sales]

  def show
    @accounts = Account.order(:name) # Ensure accounts are sorted A-Z
    @sales = @product.sales.includes(:account)

    # Apply filters
    @sales = @sales.where(account_id: params[:account_id]) if params[:account_id].present?
    @sales = @sales.where("quantity >= ?", params[:quantity_threshold].to_i) if params[:quantity_threshold].present?
    @sales = @sales.where(year: params[:year]) if params[:year].present?
    @sales = @sales.where(month: params[:month]) if params[:month].present?

    # Apply sorting
    @sales = @sales.order("#{sort_column} #{sort_direction}")
  end

  def export_sales
    @sales = @product.sales.includes(:account)

    # Apply filters
    @sales = @sales.where(account_id: params[:account_id]) if params[:account_id].present?
    @sales = @sales.where("quantity >= ?", params[:quantity_threshold].to_i) if params[:quantity_threshold].present?
    @sales = @sales.where(year: params[:year]) if params[:year].present?
    @sales = @sales.where(month: params[:month]) if params[:month].present?

    # Apply sorting
    @sales = @sales.order("#{sort_column} #{sort_direction}")

    respond_to do |format|
      format.csv { send_data Sale.to_csv(@sales), filename: "product-#{@product.id}-sales-#{Date.today}.csv" }
    end
  end

  private

  def set_product
    @product = Product.find_by(id: params[:id])
    unless @product
      flash[:alert] = "Product not found."
      redirect_to products_path
    end
  end

  # Helper methods for sorting
  def sort_column
    Sale.column_names.include?(params[:sort]) ? params[:sort] : "account_id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
