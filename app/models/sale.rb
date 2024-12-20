# app/models/sale.rb
require 'csv'

class Sale < ApplicationRecord
  belongs_to :account
  belongs_to :product

  def self.to_csv
    attributes = %w[account_name product_name quantity year month]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |sale|
        csv << [
          sale.account.name,
          sale.product.name,
          sale.quantity,
          sale.year,
          sale.month
        ]
      end
    end
  end
end
