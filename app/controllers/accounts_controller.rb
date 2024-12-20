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
  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    new_name = params[:account][:name]
  
    if @account.name != new_name
      # Check if new_name already exists
      existing_account = Account.find_by(name: new_name)
      if existing_account
        # Move sales from the old account to the existing account
        @account.sales.update_all(account_id: existing_account.id)
  
        # Destroy the old account
        @account.destroy
        flash[:notice] = "Accounts merged successfully."
        redirect_to accounts_path
      else
        # Just rename if no merge needed
        if @account.update(name: new_name)
          flash[:notice] = "Account name updated."
          redirect_to accounts_path
        else
          flash[:alert] = "Error updating account."
          render :edit
        end
      end
    else
      # Name hasn't changed
      redirect_to accounts_path
    end
  end
end
