require 'digest'

class ReportsController < ApplicationController
  def create
    @report = Report.new
    @report.file.attach(params[:report][:file])

    # Compute file digest
    file_contents = @report.file.download
    digest = Digest::SHA256.hexdigest(file_contents)
    @report.file_digest = digest

    if Report.exists?(file_digest: digest)
      flash[:alert] = "This report has already been uploaded."
      redirect_to reports_path
    else
      if @report.save
        # Process the file’s data to create Sales, Accounts, Products
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

  def process_sales_data(contents)
    # Parse CSV
    require 'csv'
    csv = CSV.parse(contents, headers: true)

    csv.each do |row|
      account_name = row["account"]
      product_name = row["product"]
      quantity = row["quantity"].to_i
      date_str = row["date"] # e.g. "2024-05" or something similar
      
      # Extract year, month
      # Assuming date_str is like "2024-05", adjust parsing as needed
      year, month = date_str.split("-").map(&:to_i)
      
      account = Account.find_or_create_by(name: account_name.strip)
      product = Product.find_or_create_by(name: product_name.strip)

      # Check for existing sales record for that account, product, year, month
      existing_sale = Sale.find_by(account: account, product: product, year: year, month: month)
      unless existing_sale
        Sale.create!(account: account, product: product, year: year, month: month, quantity: quantity)
      end
    end
  end
end
