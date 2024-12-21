class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    @sales = @product.sales.includes(:account) # Fetch all sales for the product with associated accounts
  end
end
