# app/models/sale.rb
require 'csv'

class Sale < ApplicationRecord
  belongs_to :account
  belongs_to :product

  # Validations
  validates :product_id, :quantity, :year, :month, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 2000, less_than_or_equal_to: Date.today.year }
  validates :month, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }

   # CSV Export
   def self.to_csv(sales = all)
    attributes = %w[Account Product Quantity Year Month]

    CSV.generate(headers: true) do |csv|
      csv << attributes
      sales.each do |sale|
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
