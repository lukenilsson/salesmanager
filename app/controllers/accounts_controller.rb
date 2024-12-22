# app/controllers/accounts_controller.rb

class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :products, :export_sales]

  def index
    @accounts = Account.order(:name) # Sort A-Z for consistency
  end

  def show
    @products = Product.order(:name) # Ensure products are sorted A-Z
    @sales = @account.sales.includes(:product)

    # Apply filters
    @sales = @sales.where(product_id: params[:product_id]) if params[:product_id].present?
    @sales = @sales.where("quantity >= ?", params[:quantity_threshold].to_i) if params[:quantity_threshold].present?
    @sales = @sales.where(year: params[:year]) if params[:year].present?
    @sales = @sales.where(month: params[:month]) if params[:month].present?

    # Apply sorting
    @sales = @sales.order("#{sort_column} #{sort_direction}")

    respond_to do |format|
      format.html
      format.csv { send_data Sale.to_csv(@sales), filename: "account-#{@account.id}-sales-#{Date.today}.csv" }
    end
  end

  def edit
    # @account is already set by before_action
  end

  def update
    new_name = params[:account][:name]

    if @account.name != new_name
      existing_account = Account.find_by(name: new_name)
      if existing_account
        @account.sales.update_all(account_id: existing_account.id)
        @account.destroy
        flash[:notice] = "Accounts merged successfully."
        redirect_to accounts_path
      else
        if @account.update(name: new_name)
          flash[:notice] = "Account name updated."
          redirect_to accounts_path
        else
          flash[:alert] = "Error updating account."
          render :edit
        end
      end
    else
      redirect_to accounts_path
    end
  end

  def products
    @sales = @account.sales.includes(:product)

    # Apply filters
    @sales = @sales.where(product_id: params[:product_id]) if params[:product_id].present?
    @sales = @sales.where("quantity >= ?", params[:quantity_threshold].to_i) if params[:quantity_threshold].present?
    @sales = @sales.where(year: params[:year]) if params[:year].present?
    @sales = @sales.where(month: params[:month]) if params[:month].present?

    # Apply sorting
    @sales = @sales.order("#{sort_column} #{sort_direction}")
  end

  def export_sales
    @sales = @account.sales.includes(:product)
  
    # Apply filters
    @sales = @sales.where(product_id: params[:product_id]) if params[:product_id].present?
    @sales = @sales.where("quantity >= ?", params[:quantity_threshold].to_i) if params[:quantity_threshold].present?
    @sales = @sales.where(year: params[:year]) if params[:year].present?
    @sales = @sales.where(month: params[:month]) if params[:month].present?
  
    # Apply sorting
    @sales = @sales.order("#{sort_column} #{sort_direction}")
  
    respond_to do |format|
      format.csv { send_data Sale.to_csv(@sales), filename: "account-#{@account.id}-sales-#{Date.today}.csv" }
    end
  end

  private

  # Set @account based on params[:id]
  def set_account
    @account = Account.find_by(id: params[:id])
    unless @account
      flash[:alert] = "Account not found."
      redirect_to accounts_path
    end
  end

  # Helper methods for sorting
  def sort_column
    Sale.column_names.include?(params[:sort]) ? params[:sort] : "product_id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
