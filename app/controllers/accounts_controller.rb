class AccountsController < ApplicationController
  def index
    @accounts = Account.all
  end

  def show
    @account = Account.find(params[:id])
    @sales = @account.sales.includes(:product)
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
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
    @account = Account.find(params[:id])
  
    # Fetch sales with product details for this account
    @sales = @account.sales.includes(:product)
  
    # Apply filters
    if params[:product_name].present?
      @sales = @sales.joins(:product).where("products.name ILIKE ?", "%#{params[:product_name]}%")
    end
  
    if params[:start_date].present? && params[:end_date].present?
      @sales = @sales.where("sales.created_at BETWEEN ? AND ?", params[:start_date], params[:end_date])
    end
  end
  
end
