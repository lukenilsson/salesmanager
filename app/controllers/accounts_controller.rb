class AccountsController < ApplicationController
  def index
    @accounts = Account.all
  end

  def show
    @account = Account.find(params[:id])
    # Load the purchase history for this account
    @sales = @account.sales.includes(:product)
    # Apply filters if needed (e.g., year, month, product, etc.)
  end
end
