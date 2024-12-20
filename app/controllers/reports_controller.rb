class ReportsController < ApplicationController
  def index
    # Display all cumulative reports, add filtering logic here
    @accounts = Account.all
    @products = Product.all

    # Apply filters
    @sales = Sale.includes(:account, :product).all
    @sales = @sales.where(account_id: params[:account_id]) if params[:account_id].present?
    @sales = @sales.where(product_id: params[:product_id]) if params[:product_id].present?
    @sales = @sales.where("quantity >= ?", params[:quantity_threshold].to_i) if params[:quantity_threshold].present?
    @sales = @sales.where(year: params[:year]) if params[:year].present?
    @sales = @sales.where(month: params[:month]) if params[:month].present?

    respond_to do |format|
      format.html # renders index.html.erb
      format.csv { send_data @sales.to_csv, filename: "sales-#{Date.today}.csv" }
    end
  end

  def new
    @report = Report.new
  end

  def create
    @report = Report.new
    @report.file.attach(params[:report][:file])
    file_contents = @report.file.download
    digest = Digest::SHA256.hexdigest(file_contents)
    @report.file_digest = digest

    if Report.exists?(file_digest: digest)
      flash[:alert] = "This report has already been uploaded."
      redirect_to reports_path
    else
      if @report.save
        process_sales_data(file_contents)
        flash[:notice] = "Report uploaded and processed."
        redirect_to dashboard_path
      else
        flash[:alert] = "Error uploading report."
        render :new
      end
    end
  end

  def export
    # This action can explicitly handle CSV exports if desired
    # For now, we rely on the index action's respond_to CSV block.
  end

  private

  def process_sales_data(contents)
    require 'csv'
    csv = CSV.parse(contents, headers: true)

    csv.each do |row|
      account_name = row["account"]
      product_name = row["product"]
      quantity = row["quantity"].to_i
      date_str = row["date"]
      year, month = date_str.split("-").map(&:to_i)

      account = Account.find_or_create_by(name: account_name.strip)
      product = Product.find_or_create_by(name: product_name.strip)

      existing_sale = Sale.find_by(account: account, product: product, year: year, month: month)
      unless existing_sale
        Sale.create!(account: account, product: product, year: year, month: month, quantity: quantity)
      end
    end
  end
end
