def show
  @account = Account.find(params[:id])
  @sales = @account.sales.includes(:product)

  # Optional filters as above
end
