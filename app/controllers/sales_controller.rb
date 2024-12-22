# app/controllers/sales_controller.rb

class SalesController < ApplicationController
  before_action :set_account
  before_action :set_sale, only: [:edit, :update, :destroy]

  def edit
    # @sale is already set by before_action
  end

  def update
    if @sale.update(sale_params)
      flash[:notice] = "Sale was successfully updated."
      redirect_to account_path(@account)
    else
      flash.now[:alert] = "There was an error updating the sale."
      render :edit
    end
  end

  def destroy
    @sale.destroy
    flash[:notice] = "Sale was successfully deleted."
    redirect_to account_path(@account)
  end

  private

  # Set @account based on params[:account_id]
  def set_account
    @account = Account.find_by(id: params[:account_id])
    unless @account
      flash[:alert] = "Account not found."
      redirect_to accounts_path
    end
  end

  # Set @sale based on params[:id] within the context of @account
  def set_sale
    @sale = @account.sales.find_by(id: params[:id])
    unless @sale
      flash[:alert] = "Sale not found."
      redirect_to account_path(@account)
    end
  end

  # Strong parameters for sale
  def sale_params
    params.require(:sale).permit(:product_id, :quantity, :year, :month)
  end
end
