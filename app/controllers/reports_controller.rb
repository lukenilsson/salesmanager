class ReportsController < ApplicationController
  include Sortable
  before_action :permit_sorting_params, only: [:index]

  def index
    @accounts = Account.order(:name) # Sort A-Z
    @products = Product.order(:name) # Sort A-Z

    @sales = Sale.includes(:account, :product).all
    @sales = @sales.where(account_id: params[:account_id]) if params[:account_id].present?
    @sales = @sales.where(product_id: params[:product_id]) if params[:product_id].present?
    @sales = @sales.where("quantity >= ?", params[:quantity_threshold].to_i) if params[:quantity_threshold].present?
    @sales = @sales.where(year: params[:year]) if params[:year].present?
    @sales = @sales.where(month: params[:month]) if params[:month].present?

    # Use the permitted parameters for sorting
    @sales = @sales.joins(:account, :product).order("#{sort_column} #{sort_direction}")

    respond_to do |format|
      format.html
      format.csv { send_data @sales.to_csv, filename: "sales-#{Date.today}.csv" }
    end
  end

  def new
    @report = Report.new
  end

  def create
    @report = Report.new
    uploaded_file = params[:report][:file]

    # Read the file's contents directly from the uploaded_file
    file_contents = uploaded_file.read

    # Compute digest
    digest = Digest::SHA256.hexdigest(file_contents)
    @report.file_digest = digest

    if Report.exists?(file_digest: digest)
      flash[:alert] = "This report has already been uploaded."
      redirect_to reports_path
    else
      # Attach the file so it's stored and can be referenced later if needed
      @report.file.attach(uploaded_file)

      if @report.save
        # Process the file’s data and insert into database
        process_sales_data(file_contents)
        flash[:notice] = "Report uploaded and processed."
        redirect_to dashboard_path
      else
        flash[:alert] = "Error uploading report."
        render :new
      end
    end
  end

  private

  # Permit sorting parameters and make them accessible
  def permit_sorting_params
    # Note: @permitted_params is not used in Sortable; sort_column and sort_direction use params directly
    params.permit(:sort, :direction, :account_id, :product_id, :quantity_threshold, :year, :month)
  end

  # Use the permitted parameters for sorting
  def sort_column
    case params[:sort]
    when "product_id"
      "products.name" # Sort by product name
    when "account_id"
      "accounts.name" # Sort by account name if applicable
    when "id"
      "sales.id" # Explicitly use sales table's id
    else
      Sale.column_names.include?(params[:sort]) ? "sales.#{params[:sort]}" : "sales.id"
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def process_sales_data(contents)
    require 'csv'
    csv = CSV.parse(contents, headers: true)

    csv.each do |row|
      account_name  = row["account"]
      product_name  = row["product"]
      quantity      = row["quantity"].to_i
      date_str      = row["date"] # e.g., "2024-05"
      year, month   = date_str.split("-").map(&:to_i)

      account = Account.find_or_create_by(name: account_name.strip)
      product = Product.find_or_create_by(name: product_name.strip)

      existing_sale = Sale.find_by(account: account, product: product, year: year, month: month)
      unless existing_sale
        Sale.create!(account: account, product: product, year: year, month: month, quantity: quantity)
      end
    end
  end
end
